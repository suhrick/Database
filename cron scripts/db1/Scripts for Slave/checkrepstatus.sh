#!/bin/bash


#Get the slave status, to see how many seconds behind the master this host is
# 8/27/14 - SUHRICK - edhoed results of check to file for tracking
#
# 9/4/14 - SGU  Moved logic for detecting null in "seconds behind" from replication monitoring script to the slave restart script
#

sbm=`mysql -e "show slave status\G"|grep "Seconds_Behind_Master"|awk -F':' '{print $2}'`
echo "db1b-dr.aws behind by $sbm seconds" >/tmp/sbm

##Remove any white space from what mysql query returns
sbm=${sbm//[[:space:]]}

#Create a string which contains all integers
re='^[0-9]+$'
if [ "$sbm" -gt 9000 ]; then
        rep_status=`mysql -e "show slave status\G"|grep "Slave_IO_State"`
        behind_contents=`mysql -e "show slave status\G"|grep "Seconds_Behind_Master"`
        report_string="$rep_status     $behind_contents"
        echo "$report_string" > /tmp/report_string
        mail -s "db1b-drb.aws Replication is $sbm Seconds Behind" databasesystems@teladoc.com </tmp/report_string
fi
z