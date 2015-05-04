#!/bin/bash

# appstack-run-irods.sh
# Author: Michael Stealey <michael.j.stealey@gmail.com>

APPSTACK_PATH=$1

# build docker appstack images
${APPSTACK_PATH}/appstack-build.sh ${1}
sleep 2s

# Launch data volume as docker container data
docker run --name data -d -v /srv/pgsql:/var/lib/pgsql/9.3/data -v /srv/irods:/var/lib/irods \
    -v /srv/log:/var/log -v /srv/backup:/var/backup -v /srv/conf:/conf -v /root/.secret -it appstack-data
sleep 2s

# Setup postgreql database
docker run --rm --volumes-from data -it appstack-setup-postgresql
sleep 2s

# Launch postgres database as docker container db
docker run -u postgres --volumes-from data --name db -d appstack-postgresql

# Setup irods environment
docker run -ti --volumes-from data --link db:db appstack-setup-irods

# Lauch irods environment as docker container icat
docker run --volumes-from data --name icat --link db:db -d appstack-irods