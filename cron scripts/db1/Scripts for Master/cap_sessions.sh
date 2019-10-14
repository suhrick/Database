#!/bin/bash
cd ~/SCRIPTS

# set $cpu by extracting the "last one minute" field from uptime
cpu=`uptime | awk '{print $10}'| sed 's/\..*//'`
# Get MySQL's current max_connections
current_cap=$(mysql -s --execute="select @@global.max_connections;")
# Get the count of current sessions
current_sessions=`mysql -e "show processlist;" | wc -l`

#if [[ $cpu -ge 30 && $cpu -lt 75 ]] ; then
if [[ $cpu -ge 30 ]] ; then
# kill sessions longer than 30 seconds
   echo "kill script run " `date` >> ~/SCRIPTS/kill_script_invoked.log
   rm -f ~/SCRIPTS/session_list.txt ~/SCRIPTS/kill_list.sql  ~/SCRIPTS/killed_sql_list.txt
   touch ~/SCRIPTS/killed_sql_list.txt
   mysql -e "select id from  information_schema.processlist where  user not in ('hexatier','repl','system user','mysql','monyog') and command='Query' and time > 30;" > ~/SCRIPTS/session_list.txt
   tail -n +2 ~/SCRIPTS/session_list.txt > x
   mv x session_list.txt
   while read p; do
     echo "kill $p ;" >> ~/SCRIPTS/kill_list.sql
     echo "Killed SQLs" > ~/SCRIPTS/killed_sql_list.txt
     mysql -e "select info, time, user, host from information_schema.processlist where id = $p;" >> ~/SCRIPTS/killed_sql_list.txt
   done < ~/SCRIPTS/session_list.txt
   mysql < ~/SCRIPTS/kill_list.sql
   mail -s "db1 Production Loading Alert!  CPU=$cpu% Active sessions will be killed after 30 seconds" database-performance-reports@teladoc.com <  ~/SCRIPTS/killed_sql_list.txt
   mail -s "db1 Production Loading Alert!  CPU=$cpu% Active sessions will be killed after 30 seconds" sysadmin@teladoc-inc.pagerduty.com <  ~/SCRIPTS/killed_sql_list.txt
fi
rm -f ~/SCRIPTS/session_list.txt ~/SCRIPTS/kill_list.sql  ~/SCRIPTS/killed_sql_list.txt

#if [[ $cpu -ge 75 ]] ; then
# Same as above but sessions capped at 50.  Other should pruned after 30 seconds.
#   mysql -e "set global max_connections=50;"
#   rm -f ~/SCRIPTS/session_list.txt ~/SCRIPTS/kill_list.sql  ~/SCRIPTS/killed_sql_list.txt
#   touch ~/SCRIPTS/killed_sql_list.txt
#   mysql -e "select id from  information_schema.processlist where  user not in ('hexatier','repl','system user','mysql','monyog') and command='Query' and time > 30;" > ~/SCRIPTS/session_list.txt
#   tail -n +2 ~/SCRIPTS/session_list.txt > x
#   mv x session_list.txt
#   while read p; do
#     echo "kill $p ;" >> ~/SCRIPTS/kill_list.sql
#     mysql -e "select info, time, user, host from information_schema.processlist where id = $p;" >> ~/SCRIPTS/killed_sql_list.txt
#   done < ~/SCRIPTS/session_list.txt
#   mysql < ~/SCRIPTS/kill_list.sql
#   mail -s "db1 Production Loading Alert!  CPU=$cpu% Active sessions will be killed after 30 seconds and capped at 50 allowed" database-performance-reports@teladoc.com <  killed_sql_list.txt
#   mail -s "db1 Production Loading Alert!  CPU=$cpu% Active sessions will be killed after 30 seconds and capped at 50 allowed" sysadmin@teladoc-inc.pagerduty.com <  killed_sql_list.txt
#fi

# Note - threshold moved to 10 for testing
#if [[ $cpu -lt 10 && $current_cap != 1000 ]] ; then
# Set to defaults
#   mysql -e "set global max_connections=1000;"
#   mail -s "Production Loading Alert Cleared CPU=$1% Max Connections reset to 1000" database-performance-reports@teladoc.com <  /dev/null
#  mail -s "Production Loading Alert Cleared CPU=$1% Max Connections reset to 1000" sysadmin@teladoc-inc.pagerduty.com <  /dev/null
#fi

exit
