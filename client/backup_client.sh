#!/bin/bash

# DistBackup Client: Downloads the backup files from DistBackup Server public dir
# unfoobar@unfoobar.com
# https://github.com/Unfoobar/distbackup
# Version: 1.0

# backup script configuration
backup_dir="/var/backups/owncloud/daily/"			# target dir
hostname="unfoobar.com"						# server host
port="22"							# server port for ssh
user="backups"							# server login username
identity_file="/home/backups/.ssh/id_rsa"			# server login ssh key
batch_file="/etc/backups/owncloud/backup_client_sftp.bat" 	# sftp batch file
storage_period="70"						# days for backups to remain in target dir (-1 for infinity)

# handle old backup files
if [ "$storage_period" -gt -1 ]
then
	find $backup_dir -type f -ctime +$storage_period -exec rm {} \;
fi

cd $backup_dir

# download backup files
sftp -i $identity_file -P $port -b $batch_file $user@$hostname

