#!/bin/bash


IMAGE=ortym/couchbase_to_s3:4.0.0

AWS_PROFILE=testing
AWS_REGION=us-east-1
S3_BUCKET=example-backup

SERVER_USER="Administrator"
SERVER_PASSWORD="secret"

BACKUP_PATH=/data
# BACKUP_REPO=example-repo # Only in 4.5

#
# Container name of the running Couchbase server
#
COUCHBASE_SERVER_CONTAINER=couchbase
#
# This is a directory on the host, where backup is persisted. Must exist.
#
HOST_BACKUP_PATH=/home/backup


[[ -d ${HOST_BACKUP_PATH} ]] || { echo "Directory ${HOST_BACKUP_PATH} does not exist."; exit 1; }

# Uncomment if SELinux enabled
# chcon -Rt svirt_sandbox_file_t ${HOST_BACKUP_PATH}

# /usr/bin/docker pull ${IMAGE}

/usr/bin/docker run \
                --link ${COUCHBASE_SERVER_CONTAINER}:couchbase \
                -e SERVER_IP="couchbase" \
                -v ~/.aws:/root/.aws \
                -v ${HOST_BACKUP_PATH}:${BACKUP_PATH} \
                -e AWS_PROFILE \
                -e AWS_REGION \
                -e S3_BUCKET \
                -e SERVER_PASSWORD \
                -e BACKUP_PATH \
                -e BACKUP_REPO \
                ${IMAGE} backup 2>&1 | tee /tmp/$(basename $0).$$.$(date +%y%m%d).log
