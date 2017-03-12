#!/bin/bash

# DistBackup Server: Creates incremental and full zip archive backups with optional encryption
# unfoobar@unfoobar.com
# https://github.com/Unfoobar/distbackup
# Version: 1.0

# backup script configuration
backup_dir="/var/backups/owncloud/"			# target dir
public_dir="/var/backups/public/"			# public backup dir
dir="/media/owncloud/data/unfoobar/files/"		# source dir
prefix="backup_oc_"					# backup archive name prefix
backup_complete="14"					# days difference to last complete backup
backup_previous="1"					# days difference to last backup at all
encryption=true						# enable pgp encryption for backup files
gpg_recipient="unfoobar@unfoobar.com"			# gpg recipient
delete_old=true						# delete old backup files

# settings
tmp_complete="tmp_complete"				# archive name for current complete backup
date_format="%Y-%m-%d"					# date format for archive names

# generate date strings
day=`date +$date_format`
previous=`date +$date_format -d "$backup_previous days ago"`

# encrypts today's backup
encrypt() {
	echo "start encryption..."
	cd $backup_dir
        gpg -e -r "$gpg_recipient" -o $public_dir$prefix$day.zip.gpg $backup_dir$prefix$day.zip
}

cd $dir

# backup
if [ ! -e "$backup_dir$tmp_complete.zip" ] || [ -f "$(find $backup_dir -type f -name "$tmp_complete.zip" -ctime +$backup_complete)" ]
then
	# complete backup
	echo "start complete backup..."

	if [ -e "$backup_dir$tmp_complete.zip" ]
	then
		echo "remove temporary complete backup..."
		rm $backup_dir$tmp_complete.zip
	fi

	echo "create new complete backup..."
	zip -r $backup_dir$prefix$day.zip .

	# encryption
	if [ "$encryption" = true ]
	then
		encrypt
	fi

	# handle old zip file
	if [ "$delete_old" = true ]
	then
		mv $backup_dir$prefix$day.zip $backup_dir$tmp_complete.zip
	else
		cp $backup_dir$prefix$day.zip $backup_dir$tmp_complete.zip
	fi
else
	# incremental backup
	echo "start incremental backup..."

	echo "create new incremental backup..."
	zip -r $backup_dir$tmp_complete.zip . -DF --out $backup_dir$prefix$day.zip

	echo "update temporary complete backup..."
	zip -r $backup_dir$tmp_complete.zip .

	# encryption
	if [ "$encryption" = true ]
	then
		encrypt
	fi

	# handle old zip file
	if [ "$delete_old" = true ] || [ "$encryption" = true ]
	then
		rm $backup_dir$prefix$day.zip
	fi
fi

# handle old gpg file
if [ "$delete_old" = true ]
then
	if [ "$encryption" = true ] && [ -e "$backup_dir$prefix$previous.zip.gpg" ]
	then
		rm $public_dir$prefix$previous.zip.gpg
	elif [ "$encryption" = false ] && [ -e "$backup_dir$prefix$previous.zip" ]
	then
		rm $public_dir$prefix$previous.zip
	fi

fi

# reset permissions
chmod -R 470 $backup_dir
