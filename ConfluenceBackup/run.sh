#!/bin/bash

set -euxo pipefail

rm -rf ./CONF-backup-*.zip

INSTANCE=corndel.atlassian.net
LOCATION=$(pwd)

. ./download-cloud-backup.sh

aws s3 cp ./CONF-backup-*.zip s3://corndel-confluence-backups
