#Go no further if load in progress
if [ -e ~/SCRIPTS/prod_load_in_progress.flg  ]
then
   exit
fi

# Test if AWS Med-History Prod Available.  If not, notify, wait for five minutes and exit.  Next cron-call will try again.
mysql -hmedhistory-cluster.cluster-clsac7ty7ejh.us-east-1.rds.amazonaws.com -uerx_loader -pcerner -e "exit"
if
   [ $? != 0 ]
then
    mail -s "Trying to Connect to Med-History erx_drugs Prod For Cernum Prod Refresh, Unavailable, will Retry" suhrick@teladoc.com <  /dev/null
#   mail -s "Trying to Connect to Med-History erx_drugs Prod For Cernum Prod Refresh, Unavailable, will Retry" raghu@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to Med-History erx_drugs Prod For Cernum Prod Refresh, Unavailable, will Retry" jdittmar@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to Med-History erx_drugs Prod For Cernum Prod Refresh, Unavailable, will Retry" jjensen@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to Med-History erx_drugs Prod For Cernum Prod Refresh, Unavailable, will Retry" jlavin@teladoc.com <  /dev/null

    sleep 300
    exit
fi

# Test if 3306 Available.  If not, notify, wait for five minutes and exit.  Next cron-call will try again.
mysql -e "exit"
if
   [ $? != 0 ]
then
    mail -s "Trying to Connect to db1 3306 For Cernum Prod Refresh, Unavailable, will Retry" suhrick@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to db1 3306 For Cernum Prod Refresh, Unavailable, will Retry" raghu@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to db1 3306 For Cernum Prod Refresh, Unavailable, will Retry" jdittmar@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to db1 3306 For Cernum Prod Refresh, Unavailable, will Retry" jjensen@teladoc.com <  /dev/null
#    mail -s "Trying to Connect to db1 3306 For Cernum Prod Refresh, Unavailable, will Retry" jlavin@teladoc.com <  /dev/null
#    sleep 300
    exit
fi

# Remove old date test file
rm -f ~/SCRIPTS/db1_cerner_database_date_prod.txt  ~/SCRIPTS/medhistory_prod_cerner_database_date.txt

# Get date of the current Med-History database load
mysql -hmedhistory-cluster.cluster-clsac7ty7ejh.us-east-1.rds.amazonaws.com -uerx_loader -pcerner erx_drugs -e "select * from database_info;" > ~/SCRIPTS/medhistory_prod_cerner_database_date.txt

# Get date of current erx_drugs Cernum load
mysql -e "select * from erx_drugs.database_info;" > ~/SCRIPTS/db1_cerner_database_date_prod.txt

# Compare the two
DIFF=$(diff ~/SCRIPTS/db1_cerner_database_date_prod.txt  ~/SCRIPTS/medhistory_prod_cerner_database_date.txt )

# If different load erx_drugs tables into Med-History AWS copy of erx_drugs
if [ "$DIFF" != "" ]
#if [ "$DIFF" != "x" ]
then
    # Drop flag saying load in progress
   touch  ~/SCRIPTS/prod_load_in_progress.flg
   mail -s "New Cernum Data Detected, Refreshing Prod" suhrick@teladoc.com <  /dev/null
   mail -s "New Cernum Data Detected, Refreshing Prod" raghu@teladoc.com <  /dev/null
   mail -s "New Cernum Data Detected, Refreshing Prod" jdittmar@teladoc.com <  /dev/null
   mail -s "New Cernum Data Detected, Refreshing Prod" jjensen@teladoc.com <  /dev/null
   mail -s "New Cernum Data Detected, Refreshing Prod" jlavin@teladoc.com <  /dev/null

   # Load the first of two erx prod databases
   # Dump erx_drugs into Med-History AWS copy of erx_drugs staging
   mysqldump erx_drugs | mysql -hmedhistory-cluster.cluster-clsac7ty7ejh.us-east-1.rds.amazonaws.com -uerx_loader -pcerner erx_drugs_load
   # Get list of erx_tables to be used to rename AWS Med-History tables
   mysql -e " select table_name from information_schema.tables where table_schema = 'erx_drugs';" > ~/SCRIPTS/erx_drug_table_list_prod.txt
   # Remove first line
   sed -i -e "1d"  ~/SCRIPTS/erx_drug_table_list_prod.txt
   # Remove old alter table file
   rm -f ~/SCRIPTS/rename_erx_tables_prod.sql
   # Turn list of erx_drugs table names into alter table commands
   while read p; do
      echo "alter table erx_drugs_load.$p rename  erx_drugs.$p;" >> ~/SCRIPTS/rename_erx_tables_prod.sql
   done <  ~/SCRIPTS/erx_drug_table_list_prod.txt
   # Drop and recreate current AWS Med-History erx_drugs `database
   mysql -hmedhistory-cluster.cluster-clsac7ty7ejh.us-east-1.rds.amazonaws.com -uerx_loader -pcerner -e "drop database erx_drugs;"
   mysql -hmedhistory-cluster.cluster-clsac7ty7ejh.us-east-1.rds.amazonaws.com -uerx_loader -pcerner -e "create database erx_drugs;"
   # rename tables to place loading schema tables into main Med-History AWS erx_drugs database
   mysql -hmedhistory-cluster.cluster-clsac7ty7ejh.us-east-1.rds.amazonaws.com -uerx_loader -pcerner < ~/SCRIPTS/rename_erx_tables_prod.sql
   if
      [ $? != 0 ]
   then
       mail -s "Refresh of MedHistory Prod (AWS) From db1 Failed" suhrick@teladoc.com <  /dev/null
       mail -s "Refresh of MedHistory Prod (AWS) From db1 Failed" raghu@teladoc.com <  /dev/null
       mail -s "Refresh of MedHistory Prod (AWS) From db1 Failed" jdittmar@teladoc.com <  /dev/null
       mail -s "Refresh of MedHistory Prod (AWS) From db1 Failed" jjensen@teladoc.com <  /dev/null
       mail -s "Refresh of MedHistory Prod (AWS) From db1 Failed" jlavin@teladoc.com <  /dev/null
   else
        mail -s "Prod AWS Med-History erx_drugs refreshed successfully" suhrick@teladoc.com <  /dev/null
        mail -s "Prod AWS Med-History erx_drugs refreshed successfully" raghu@teladoc.com <  /dev/null
        mail -s "Prod AWS Med-History erx_drugs refreshed successfully" jdittmar@teladoc.com <  /dev/null
        mail -s "Prod AWS Med-History erx_drugs refreshed successfully" jjensen@teladoc.com <  /dev/null
        mail -s "Prod AWS Med-History erx_drugs refreshed successfully" jlavin@teladoc.com <  /dev/null
   fi
fi
rm -f ~/SCRIPTS/db1_cerner_database_date_prod.txt ~/SCRIPTS/medhistory_prod_cerner_database_date.txt  ~/SCRIPTS/erx_drug_table_list_prod.txt ~/SCRIPTS/rename_erx_tables_prod.sql ~/SCRIPTS/prod_load_in_progress.flg
