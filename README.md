# Docker Backup Manager

The Docker Backup Manager (DBM) is a docker image to back up the database and ldap server inside your docker container.

## Packages
* mariadb-client (`mysql` and `mysqldump`)
* postgresql-client (`psql` and `pg_dump`)
* mongodb (`mongo`)
* mongodb-tools (`mongodump`)
* openldap-clients (`ldapsearch`)

## Usage
This repository contains a [`docker-compose.yml`](./docker-compose.yml), which can be used to test the image.
```shell
docker run --rm -it \
  -v "/var/backups/:/data/" \
  --env-file .dbm.env \
  --network=dbm_default \
  ghcr.io/felbinger/dbm
```

If you'd like to execute the backup using a cronjob, you need to to remove the parameter `-it` from the command.
```shell
# run database backup every three hours
0 */3 * * * /bin/bash /root/db_backup.sh >/dev/null 2>&1
```

## Environment Variables
|      Variable Name     |                    Description                   | Default Value |
|------------------------|--------------------------------------------------|---------------|
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
