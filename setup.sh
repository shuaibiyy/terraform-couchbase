#!/usr/bin/env bash

cb_version=$1
cb_password=$2
mount_dir="/data"
backup_dir="${mount_dir}/backup"

# Mount EBS snapshot.
sudo mkdir -p ${backup_dir}
sudo mount /dev/xvdf ${mount_dir}
sudo chmod -R 777 ${mount_dir}

# Install Couchbase
wget http://packages.couchbase.com/releases/${cb_version}/couchbase-server-enterprise_${cb_version}-ubuntu14.04_amd64.deb
sudo dpkg -i couchbase-server-enterprise_${cb_version}-ubuntu14.04_amd64.deb

# Create backup script.
echo "/opt/couchbase/bin/cbbackup http://localhost:8091 ${backup_dir} -u Administrator -p ${cb_password} -b default" > $HOME/cron.sh
chmod +x $HOME/cron.sh

# Create cronjob for backup.
(crontab -l 2>/dev/null; echo "*/2 * * * * $HOME/cron.sh -with args") | crontab -

# If backup exists, restore it.
# Won't work because backup directory is unknown. Also, DB needs to be setup before trying to restore backup.
# Workaround is to manually SSH into instance, find out backup directory and run restore command below - all after setting up the server through the UI dashboard.
#if [ -d ${backup_dir} ]; then
#    /opt/couchbase/bin/cbrestore ${backup_dir} http://localhost:8091 --bucket-source=default --bucket-destination=default -u Administrator -p ${cb_password}
#fi
