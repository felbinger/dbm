FROM alpine:3.16.3

ENV LDAP_PORT=389 \
    LDAP_SCHEMA='ldap' \
    MARIADB_PORT=3306 \
    MARIADB_USERNAME='backup' \
    POSTGRES_PORT=5432 \
    POSTGRES_USERNAME='backup' \
    MONGODB_PORT=27017 \
    MONGODB_USERNAME='backup' \
    MONGODB_AUTH_DB='admin' \
    MONGODB_AUTH_MECHANISM='SCRAM-SHA-1' \
    TZ='Europe/Berlin' \
    DATE_FORMAT=long

RUN apk add --update --no-cache tzdata openldap-clients \
  mariadb-client postgresql-client

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
