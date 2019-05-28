#!/bin/bash
# get (secret) parameters
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")
mkdir -p -- $TMP_DIR
cd $TMP_DIR
source $DIR/general.secret.conf


# download git LIAM2 and LIAM2-client directly in the right volume + change owner
sudo cd /var/lib/docker/volumes/TEST-LIAM2-www-data/_data
sudo git fetch --all && git reset --hard origin/master
sudo cd /var/lib/docker/volumes/TEST-LIAM2-CLIENT-www-data/_data
sudo git fetch --all && git reset --hard origin/master
sudo chown -R www-data:www-data /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data/