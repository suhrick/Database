#          Nightly archive of ERX data
# !!!!!!!!!!!!!!!!!! NOTE  !!!!!!!!!!!!!!!!!!!!!!!!!
# **************** This must NEVER be run on a slave!  ***************
#mysql backup_archive < /var/lib/mysql/SCRIPTS/Redmine_32713_ERX_Archiving.sql
# ###################################################
#          Nightly archive of Serialized Data Snapshots
# !!!!!!!!!!!!!!!!!! NOTE  !!!!!!!!!!!!!!!!!!!!!!!!!
# **************** This must NEVER be run on a slave!  ***************
mysql backup_archive < /var/lib/mysql/SCRIPTS/Redmine_33671.sql
######################################################################
#         Nightly archive of person_timelog
# **************** This must NEVER be run on a slave!  ***************
#mysql backup_archive < /var/lib/mysql/SCRIPTS/Redmine_37347_DDL_Person_TimeLogs_Cleanup_ARCHIVE.sql
####################################################################################################
