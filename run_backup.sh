#!/bin/bash


IMAGE=cbbackup

AWS_PROFILE=testing
AWS_REGION=us-east-1
S3_BUCKET=example-backup

SERVER_USER="Administrator"
SERVER_PASSWORD="secret"

BACKUP_PATH=/data
BACKUP_REPO=example-repo

#
# Container name of the running Couchbase server
#
COUCHBASE_SERVER_CONTAINER=couchbase
#
# This is a directory on the host, where backup is persisted. Must exist.
#
HOST_BACKUP_PATH=/home/backup


[[ -d ${HOST_BACKUP_PATH} ]] || { echo "Directory ${HOST_BACKUP_PATH} does not exist."; exit 1; }


/usr/bin/docker run \
                --link ${COUCHBASE_SERVER_CONTAINER}:couchbase \
                -e SERVER_URI="couchbase://couchbase" \
                -v ~/.aws:/root/.aws \
                -v ${HOST_BACKUP_PATH}:${BACKUP_PATH} \
                -e AWS_PROFILE \
                -e AWS_REGION \
                -e S3_BUCKET \
                -e SERVER_PASSWORD \
                -e BACKUP_PATH \
                -e BACKUP_REPO \
                ${IMAGE} backup
