# Docker Backup Manager

The Docker Backup Manager (DBM) is a docker image to back up the database and ldap server inside your docker container.

## Packages
* mariadb-client (`mysql` and `mysqldump`)
* postgresql-client (`psql` and `pg_dump`)
* mongodb (`mongodb`, from alpine v3.9)
* mongodb-tools (`mongodump`)
* openldap-clients (`ldapsearch`)

## Usage
This repository contains a [`docker-compose.yml`](./docker-compose.yml), which can be used to test the image.
```shell
docker run --rm -it \
  -v '/var/backups/:/data/' \
  -e "LDAP_HOST=main_ldap_1" \
  -e "LDAP_BASE_DN=dc=domain,dc=de" \
  -e "LDAP_BIND_DN=cn=admin,dc=domain,dc=de" \
  -e "LDAP_BIND_PW=S3cr3T" \
  -e "MARIADB_HOST=main_mariadb_1" \
  -e "MARIADB_DATABASES=mysql mariadb_backup nonexistent" \
  -e "MARIADB_PASSWORD=S3cr3T" \
  -e "MARIADB_USERNAME=root" \
  -e "POSTGRES_HOST=main_postgres_1" \
  -e "POSTGRES_USERNAME=postgres" \
  -e "POSTGRES_PASSWORD=S3cr3T" \
  -e "POSTGRES_DATABASES=postgres_backup postgres nonexistent" \
  -e "MONGO_HOST=main_mongo_1" \
  -e "MONGO_PASSWORD=S3cr3T" \
  -e "MONGO_DATABASES=admin nonexistent" \
  --network=dbm_default \
  ghcr.io/felbinger/dbm
```

## Environment Variables
|      Variable Name     |                    Description                   | Default Value |
|:----------------------:|:------------------------------------------------:|:-------------:|
| LDAP_SCHEMA            | LDAP schema to use (`ldap` / `ldaps`)            | ldap          |
| LDAP_HOST              | Container name of the ldap container.            |               |
| LDAP_PORT              | Port of the ldap server.                         | 389           |
| LDAP_BASE_DN           |                                                  |               |
| LDAP_BIND_DN           |                                                  |               |
| LDAP_BIND_PW           |                                                  |               |
| MARIADB_HOST           | Container name of the mariadb container.         |               |
| MARIADB_PORT           | Port of the mariadb server.                      | 3306          |
| MARIADB_USERNAME       | Username of the backup user.                     | backup        |
| MARIADB_PASSWORD       | Password of the backup user.                     |               |
| MARIADB_DATABASES      | Databases that should be included in the backup. |               |
| POSTGRES_HOST          | Container name of the postgresql container.      |               |
| POSTGRES_PORT          | Port of the postgres server.                     | 5432          |
| POSTGRES_USERNAME      | Username of the backup user.                     | backup        |
| POSTGRES_PASSWORD      | Password of the backup user.                     |               |
| POSTGRES_DATABASES     | Databases that should be included in the backup. |               |
| MONGODB_HOST           | Container name of the mongodb container.         |               |
| MONGODB_PORT           | Port of the mongodb server.                      | 27017         |
| MONGODB_USERNAME       | Username of the backup user.                     | backup        |
| MONGODB_PASSWORD       | Password of the backup user.                     |               |
| MONGODB_DATABASES      | Databases that should be included in the backup. |               |
| MONGODB_AUTH_DB        | Authentication Database                          | admin         |
| MONGODB_AUTH_MECHANISM | Authentication Mechanism                         | SCRAM-SHA-1   |
