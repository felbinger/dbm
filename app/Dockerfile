FROM alpine:3.13

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
    TZ='Europe/Berlin'

# add alpine v3.9 repositories for mongo binary from mongodb package and install packages
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' >> /etc/apk/repositories \
 && echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories \
 && apk add --update --no-cache tzdata openldap-clients mariadb-client \
  postgresql-client=13.1-r2 mongodb-tools mongodb yaml-cpp=0.6.2-r2

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
