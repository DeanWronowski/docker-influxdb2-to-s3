#!/bin/bash

set -e

: ${S3_BUCKET:?"S3_BUCKET env variable is required"}
: ${BUCKET:?"BUCKET env variable is required"}
: ${INFLUX_ORG:?"INFLUX_ORG env variable is required"}
: ${INFLUX_TOKEN:?"INFLUX_TOKEN env variable is required"}
: ${INFLUX_HOST:?"INFLUX_HOST env variable is required"}

if [[ -z ${S3_KEY_PREFIX} ]]; then
  export S3_KEY_PREFIX=""
else
  if [ "${S3_KEY_PREFIX: -1}" != "/" ]; then
    export S3_KEY_PREFIX="${S3_KEY_PREFIX}/"
  fi
fi

export BACKUP_PATH=${BACKUP_PATH:-/data/influxdb/backup}
export BACKUP_ARCHIVE_PATH=${BACKUP_ARCHIVE_PATH:-${BACKUP_PATH}.tgz}
export DATETIME=$(date "+%Y%m%d%H%M%S")

cron() {
  echo "Starting backup cron job with frequency '$1'"
  echo "$1 $0 backup" > /var/spool/cron/crontabs/root
  crond -f
}

backup() {
  echo "Backing up $BUCKET to $BACKUP_PATH"
  rm -rf $BACKUP_PATH && mkdir -p $BACKUP_PATH
  influx backup --host $INFLUX_HOST --org $INFLUX_ORG --bucket $BUCKET $BACKUP_PATH
  tar -cvzf $BACKUP_ARCHIVE_PATH $BACKUP_PATH
  echo "Sending file to S3"
  aws s3 rm s3://${S3_BUCKET}/${S3_KEY_PREFIX}latest.tgz || echo "No latest backup exists in S3"
  aws s3 cp $BACKUP_ARCHIVE_PATH s3://${S3_BUCKET}/${S3_KEY_PREFIX}latest.tgz
  aws s3api copy-object --copy-source ${S3_BUCKET}/${S3_KEY_PREFIX}latest.tgz --key ${S3_KEY_PREFIX}${DATETIME}.tgz --bucket $S3_BUCKET
  echo "Done"
}

restore() {
  rm -rf $BACKUP_PATH $BACKUP_ARCHIVE_PATH
  echo "Downloading latest backup from S3"
  aws s3 cp s3://${S3_BUCKET}/${S3_KEY_PREFIX}latest.tgz $BACKUP_ARCHIVE_PATH
  tar -xvzf $BACKUP_ARCHIVE_PATH -C /
  echo "Running restore"
  influx restore --host $INFLUX_HOST --org $INFLUX_ORG --token $INFLUX_TOKEN --bucket $BUCKET $BACKUP_PATH
  echo "Done"
}

case "$1" in
  "cron")
    cron "$2"
    ;;
  "backup")
    backup
    ;;
  "restore")
    restore
    ;;
  *)
    echo "Invalid command '$@'"
    echo "Usage: $0 {backup|restore|cron <pattern>}"
    ;;
esac
