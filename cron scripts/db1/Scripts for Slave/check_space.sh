# Call with a single parameter, the value in Gig you want to mail out when the MySQL data directory falls below
# eg., if you want to know when there is less that 100G remaining, use;
# check_space.sh 100
# Note: the my.cnf file needs to be in the default directory (/etc)

threshold_g=$1
threshold_k=`expr $1 \* 1024 \* 1024`
#echo $threshold_g
#echo $threshold_k

mycnf_line=`grep -i datadir /etc/my.cnf | awk '{print$3}'`

space=`df -hk $mycnf_line | tail -1 | awk '{print$3}'`

if [[ $space -lt $threshold_k ]] ; then
        mail -s "MySQL Data Directory Freespace Below Threshold of $threshold_g Gig"  suhrick@teladoc.com </dev/null
        mail -s "MySQL Data Directory Freespace Below Threshold of $threshold_g Gig"  raghu@teladoc.com </dev/null
#        echo Lowspace, need to mail out
fi
