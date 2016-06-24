#!/bin/bash
#
# Backup script for  Couchbase 4.5 and up
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/opt/couchbase/bin

set -e

: ${AWS_PROFILE:=testing}
: ${AWS_REGION:=us-east-1}
: ${S3_BUCKET:=example-backup}

: ${SERVER_IP:="127.0.0.1"}
: ${SERVER_USER:="Administrator"}
: ${SERVER_PASSWORD:="secret"}

: ${BACKUP_PATH:=/data}
: ${BACKUP_REPO:=example-repo}
: ${RECOVERY_PATH:=/data_recovery}

# ========================================================================================
# END of configuration
# ========================================================================================
SERVER_URI="couchbase://${SERVER_IP}"

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
                     ${RECOVERY_PATH}
}

run_backup () {
  cbbackupmgr backup --archive ${BACKUP_PATH} --repo ${BACKUP_REPO} \
              --host ${SERVER_URI} \
              --username ${SERVER_USER}\
              --password ${SERVER_PASSWORD}
}

merge_backup () {
  cbbackupmgr merge --archive ${BACKUP_PATH} --repo ${BACKUP_REPO}
}

configure () {
  cbbackupmgr config --archive ${BACKUP_PATH} --repo ${BACKUP_REPO}
}

do_backup () {
  configure
  run_backup
  merge_backup
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
