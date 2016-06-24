#!/bin/bash
#
# Backup script for pre 4.5 Couchbase
#


set -e

: ${AWS_PROFILE:=testing}
: ${AWS_REGION:=us-east-1}
: ${S3_BUCKET:=example-backup}

: ${SERVER_IP:="127.0.0.1"}
: ${SERVER_USER:="Administrator"}
: ${SERVER_PASSWORD:="secret"}

: ${BACKUP_PATH:=/data}
: ${BACKUP_REPO:=example-repo}
: ${RESTORE_BUCKETS:="default beer-sample"}

# ========================================================================================
# END of configuration
# ========================================================================================

SERVER_URI="http://${SERVER_IP}:8091"

sync_s3_up () {
  AWS_DEFAULT_PROFILE=${AWS_PROFILE} \
                     aws --region=${AWS_REGION} \
                     s3 sync  \
                     ${BACKUP_PATH} \
                     s3://${S3_BUCKET}/${BACKUP_PATH}
}

sync_s3_down () {
  AWS_DEFAULT_PROFILE=${AWS_PROFILE} \
                     aws --region=${AWS_REGION} \
                     s3 sync \
                     s3://${S3_BUCKET}/${BACKUP_PATH} \
                     ${BACKUP_PATH}
}

run_backup () {
  cbbackup ${SERVER_URI} ${BACKUP_PATH} \
           -u ${SERVER_USER} \
           -p ${SERVER_PASSWORD}
}

restore_backup () {
  local bucket
  for bucket in ${RESTORE_BUCKETS}; do
    echo Restoring ${bucket} bucket
    cbrestore ${BACKUP_PATH} couchbase://${SERVER_IP}:8091 \
              --bucket-source=${bucket}
  done
}


configure () {
  mkdir -p ${BACKUP_PATH}
}

do_backup () {
  configure
  run_backup
  sync_s3_up
}

do_restore () {
  sync_s3_down
  restore_backup
}

main () {
  case $1 in

    backup)
      echo "Starting Couchbase Server Backup "
      do_backup
      ;;

    restore)
      echo "Starting Couchbase Server restore "
      do_restore
      ;;

    -h|--help|-\?)
      echo "usage: $0 backup|restore"
      exit 1
      ;;

    *)
      exec "$@"
  esac
}

main $@
