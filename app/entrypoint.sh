#!/bin/sh

if [ -z "${LDAP_HOST}" ] \
  && [ -z "${MARIADB_HOST}" ] \
  && [ -z "${POSTGRES_HOST}" ] \
  && [ -z "${MONGODB_HOST}" ]
then
  echo "Nothing to do. Exiting..."
  exit 1
fi

DATE=""
# shellcheck disable=SC3014
if [ "${DATE_FORMAT}" == "long" ]; then
  DATE=$(date +"%Y-%m-%d_")
fi
# time in format HH-MM round to 15 minutes blocks
DATE=${DATE}$(date +"%H")-$(echo "$(date +%M) - ($(date +%M)%15)" | bc)

if [ -n "${LDAP_HOST}" ]; then
  mkdir -p "/data/${DATE}"
  echo "Starting LDAP (${LDAP_HOST}) Export"
  # check if the required arguments are provided
  if [ -n "${LDAP_BASE_DN}" ] && [ -n "${LDAP_BIND_DN}" ] && [ -n "${LDAP_BIND_PW}" ]; then
    # export
    # shellcheck disable=SC2153
    ldapsearch -x \
      -H "ldap://${LDAP_HOST}:${LDAP_PORT}" \
      -b "${LDAP_BASE_DN}" \
      -D "${LDAP_BIND_DN}" \
      -w "${LDAP_BIND_PW}" > "/data/${DATE}/${LDAP_HOST}.ldif"
  else
    if [ -z "${LDAP_BASE_DN}" ]; then
      echo "Missing environment variables: LDAP_BASE_DN"
    fi
    if [ -z "${LDAP_BIND_DN}" ]; then
      echo "Missing environment variables: LDAP_BIND_DN"
    fi
    if [ -z "${LDAP_BIND_PW}" ]; then
      echo "Missing environment variables: LDAP_BIND_PW"
    fi
  fi
fi

if [ -n "${MARIADB_HOST}" ] && [ -n "${MARIADB_PORT}" ]; then
  echo "Starting MariaDB (${MARIADB_HOST}) Backup"
  mkdir -p "/data/${DATE}/${MARIADB_HOST}/"

  # check if the required arguments are provided
  if [ -n "${MARIADB_PASSWORD}" ] && [ -n "${MARIADB_DATABASES}" ]; then

    for database_name in ${MARIADB_DATABASES}; do
      # check if database exist
      query="SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME=\"${database_name}\""
      result=$(mysql \
        --protocol=tcp \
        --host="${MARIADB_HOST}" \
        --port="${MARIADB_PORT}" \
        --user="${MARIADB_USERNAME}" \
        --password="${MARIADB_PASSWORD}" \
        -qfsBe "${query}" 2>&1)
      if [ -z "$(echo "${result}" | tail -n +1)" ]; then
        printf "\e[33mWarning: MariaDB database %s does not exist\!\e[0m\n" "${database_name}"
      else
        # backup database
        mysqldump \
          --protocol=tcp \
          --host="${MARIADB_HOST}" \
          --port="${MARIADB_PORT}" \
          --user="${MARIADB_USERNAME}" \
          --password="${MARIADB_PASSWORD}" \
          "${database_name}" > "/data/${DATE}/${MARIADB_HOST}/${database_name}.sql"
        fi
    done
  else
    if [ -z "${MARIADB_PASSWORD}" ]; then
      echo "Missing environment variables: MARIADB_PASSWORD"
    fi
    if [ -z "${MARIADB_DATABASE}" ]; then
      echo "Missing environment variables: MARIADB_DATABASE"
    fi
  fi
fi

if [ -n "${POSTGRES_HOST}" ] && [ -n "${POSTGRES_PORT}" ]; then
  echo "Starting PostgreSQL (${POSTGRES_HOST}) Backup"
  mkdir -p "/data/${DATE}/${POSTGRES_HOST}/"

  # check if the required arguments are provided
  if [ -n "${POSTGRES_PASSWORD}" ] && [ -n "${POSTGRES_DATABASES}" ]; then

    # set password for postgres binaries
    export PGPASSWORD="${POSTGRES_PASSWORD}"

    for database_name in ${POSTGRES_DATABASES}; do
      # check if database exist

      # shellcheck disable=SC2069
      psql --host "${POSTGRES_HOST}" \
        --port "${POSTGRES_PORT}" \
        --username="${POSTGRES_USERNAME}" \
        -lqt | cut -d \| -f 1 | grep -q "${database_name}" 2>&1 > /dev/null

      # shellcheck disable=SC2181
      if [ ${?} -ne 0 ]; then
        printf "\e[33mWarning: PostgreSQL database %s does not exist!\e[0m\n" "${database_name}"
      else
        # backup database
        pg_dump \
          --host "${POSTGRES_HOST}" \
          --port="${POSTGRES_PORT}" \
          --username="${POSTGRES_USERNAME}" \
          "${database_name}" \
          --file="/data/${DATE}/${POSTGRES_HOST}/${database_name}.sql"
      fi
    done
  else
    if [ -z "${POSTGRES_PASSWORD}" ]; then
      echo "Missing environment variables: POSTGRES_PASSWORD"
    fi
    if [ -z "${POSTGRES_DATABASE}" ]; then
      echo "Missing environment variables: POSTGRES_DATABASE"
    fi
  fi
fi

if [ -n "${MONGODB_HOST}" ] && [ -n "${MONGODB_PORT}" ]; then
  echo "Starting MongoDB (${MONGODB_HOST}) Backup"
  mkdir -p "/data/${DATE}/${MONGODB_HOST}/"

  # check if the required arguments are provided
  if [ -n "${MONGODB_PASSWORD}" ] && [ -n "${MONGODB_DATABASES}" ]; then
    for database_name in ${MONGODB_DATABASES}; do
      # check if database exist
      check=$(mongo --quiet \
        --host="${MONGODB_HOST}" \
        --port="${MONGODB_PORT}" \
        --username="${MONGODB_USERNAME}" \
        --password="${MONGODB_PASSWORD}" \
        --eval "db.getMongo().getDBNames().indexOf(\"${database_name}\")")
      if [ "${check}" -lt 0 ]; then
        printf "\e[33mWarning: MongoDB database %s does not exist!\e[0m\n" "${database_name}"
      else
        mongodump --quiet \
          --host="${MONGODB_HOST}" \
          --port="${MONGODB_PORT}" \
          --username="${MONGODB_USERNAME}" \
          --password="${MONGODB_PASSWORD}" \
          --authenticationDatabase="${MONGODB_AUTH_DB}" \
          --authenticationMechanism="${MONGODB_AUTH_MECHANISM}" \
          --db="${database_name}" --out "/data/${DATE}/${MONGODB_HOST}/"
      fi
    done
  else
    if [ -z "${MONGODB_PASSWORD}" ]; then
      echo "Missing environment variables: MONGODB_PASSWORD"
    fi
    if [ -z "${MONGODB_DATABASES}" ]; then
      echo "Missing environment variables: MONGODB_DATABASES"
    fi
  fi
fi
