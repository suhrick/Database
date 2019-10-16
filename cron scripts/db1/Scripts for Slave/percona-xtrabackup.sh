#!/bin/bash
#
# Put me in cron.daily, cron.hourly or cron.d for your own custom schedule
#
# Adding ulimit increase
ulimit -n 50000

rm -rf /local_backup/*

# Remove old backups in the off-server storage
find /backup2/xtrabackup/* -type d -ctime +3 | xargs rm -rf

LOG_FILE="/var/lib/mysql/SCRIPTS/backup.log"

function logit {
echo "[`date +%Y-%m-%d-%H:%M:%S`] - ${*}" >> ${LOG_FILE}
}

# Running daily? You'll keep 3 daily backups
# Running hourly? You'll keep 3 hourly backups
NUM_BACKUPS_TO_KEEP=1

# Who wants to know when the backup failed, or
# when the binary logs didn't get applied
EMAIL=DatabaseSystems@teladoc.com

# Where you keep your backups
#BACKUPDIR=/backup/xtrabackup
# Oct 19 2017 - Backing up to a local drive which is then moved to storage
BACKUPDIR=/local_backup

# path to innobackupex
XTRABACKUP=/usr/bin/innobackupex

# Add any other files you never want to remove
NEVER_DELETE="lost\+found|\.|\.."

# The mysql user able to access all the databases
OPTIONS="--user=mysql --parallel=4 --tmpdir=/local_backup/tmp"

# Shouldn't need to change these...
APPLY_LOG_OPTIONS="--apply-log --export"
BACKUP="$XTRABACKUP $OPTIONS $BACKUPDIR"
APPLY_BINARY_LOG="$XTRABACKUP $OPTIONS $APPLY_LOG_OPTIONS"
PREV=`ls -rt $BACKUPDIR | tail -n $((NUM_BACKUPS_TO_KEEP+1)) | head -n1 | egrep -v $NEVER_DELETE`

#Making sure there is a temp directory on local_backup
mkdir /local_backup/tmp

# run a backup
logit "INFO: Starting backup. backup dir: $BACKUPDIR"
$BACKUP

if [ $? == 0 ]; then
        # we got a backup, now we need to apply the binary logs
        logit "Applying binary logs"
        MOST_RECENT=$(ls -rt $BACKUPDIR | tail -n1)
        $APPLY_BINARY_LOG $BACKUPDIR/$MOST_RECENT
        if [ $? == 0 ]; then
        logit "Binary logs applied to: $BACKUPDIR/$MOST_RECENT"
                 mail -s "Backup of db1a.us3 = Success" $EMAIL < /dev/null
                # only remove if $PREV is set
                if [ -n "$PREV" ]; then
                        # remove backups you don't want to keep
                        logit "INFO: Removing $BACKUPDIR/$PREV - previous backup"
                        rm -rf $BACKUPDIR/$PREV
                fi
        else
                echo "Couldn't apply the binary logs to the backup $BACKUPDIR/$MOST_RECENT" | mail $EMAIL -s "Mysql binary log didn't get applied to backup"
                logit "Couldn't apply the binary logs to the backup $BACKUPDIR/$MOST_RECENT" | mail $EMAIL -s "Mysql binary log didn't get applied to backup"
        fi

else
        # problem with initial backup :(
        logit "ERROR: xtrabackup failed, sending email to $EMAIL"
        echo "Couldn't do a Percona backup on db1a.us3" | mail $EMAIL -s "db1a.us3 Percona backup failed"
fi

mysql -hdb1b.us3.teladoc.com --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''" | mysql -hdb1b.us3.teladoc.com --skip-column-names -A | sed 's/$/;/g' > $BACKUPDIR/$MOST_RECENT/Master_Grants.sql
if [ $? == 0 ]; then
    logit "Successfully gathered user grants from master"
else
    echo "Couldn't gather user privileges from master" | mail $EMAIL -s "Couldn't gather user privileges from master"
    logit "Couldn't gather user privileges from master" | mail $EMAIL -s "Couldn't gather user privileges from master"
fi

logit "INFO:backup completed"

# Oct 19 2017 - Backing up to a local drive which is then moved to storage
cp -rf /local_backup/* /backup2/xtrabackup
if [ $? == 0 ]; then
    logit "Successfully moved backup off-server"
else
    echo "db1a backup failed to move to off-server storage" | mail $EMAIL -s "db1a backup failed to move to off-server storage"
    logit "db1a backup failed to move to off-server storage"
fi
