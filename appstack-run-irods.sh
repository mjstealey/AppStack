#!/bin/bash

# appstack-run-irods.sh
# Author: Michael Stealey <michael.j.stealey@gmail.com>

APPSTACK_PATH=$1

# build docker appstack images
${APPSTACK_PATH}/appstack-build.sh ${1}

# Launch data volume as docker container data
docker run --name data -d -v /srv/pgsql:/var/lib/pgsql/9.3/data -v /srv/irods:/var/lib/irods -v /srv/log:/var/log \
    -v /srv/backup:/var/backup -v /srv/conf:/conf -v /root/.secret -it appstack-data

# Setup postgreql database
docker run --rm --volumes-from data -it appstack-setup-postgresql

# Launch postgres database as docker container db
docker run -u postgres --volumes-from data --name db -d appstack-postgresql

# Setup irods environment

# Lauch irods environment as docker container icat
