cnt=`mysql -e "show slave status\G;"|egrep 'Lock wait|Deadlock'|wc -l`
if [ $cnt -gt 0 ];then
   echo "in loop"
   mysql -A teladoc_eds -e  "SHOW GLOBAL STATUS like 'slave_running'; show slave status\G;  show engine innodb status\G;" >  /tmp/slave_start_reason.txt
   cat /tmp/slave_start_reason.txt  >> /tmp/replication_check_log.txt
   mail -s "Deadlock or Lockwait, db1b-dr.aws Slave Restarted" raghu@teladoc.com < /tmp/slave_start_reason.txt
   mail -s "Deadlock or Lockwait, db1b-dr.aws Slave Restarted" suhrick@teladoc.com < /tmp/slave_start_reason.txt
   mysql -A teladoc_eds -e "start slave;"
fi

#
# 9/4/14 - SGU  Moved logic for detecting null in "seconds behind" from replication monitoring script to the slave restart script
#
sbm=`mysql -e "show slave status\G"|grep "Seconds_Behind_Master"|awk -F':' '{print $2}'`
echo "db1b-dr.aws behind by $sbm seconds" >/tmp/sbm

##Remove any white space from what mysql query returns
sbm=${sbm//[[:space:]]}

#Create a string which contains all integers
re='^[0-9]+$'

#Check to see if the sbm variable does NOT contain integers. This would mean that the slave status returned maybe a NULL.
if ! [[ $sbm =~ $re ]] ; then
        mysql -A teladoc_eds -e  "SHOW GLOBAL STATUS like 'slave_running'; show slave status\G; show engine innodb status\G;" >  /tmp/slave_status.txt
        mail -s "db1b-dr.aws slave is not a number, restarting slave"  suhrick@teladoc.com </tmp/slave_status.txt
        mail -s "db1b-dr.aws slave is not a number, restarting slave"  raghu@teladoc.com </tmp/slave_status.txt
        mysql -A teladoc_eds -e "start slave;"
fi
