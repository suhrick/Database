rm -f ~/SCRIPTS/redmine_34325_daily.txt
mysql teladoc_eds < ~/SCRIPTS/redmine_34325_daily.sql >  ~/SCRIPTS/redmine_34325_daily.txt
if
   [ $? != 0 ]
then
   mail -s "Daily run of Registration Variance procedure failed!" suhrick@teladoc.com < /dev/null
   mail -s "Daily run of Registration Variance procedure failed!" raghu@teladoc.com < /dev/null
   mail -s "Daily run of Registration Variance procedure failed!" adias@teladoc.com < /dev/null
   mail -s "Daily run of Registration Variance procedure failed!" ghochron@teladoc.com < /dev/null
else
   mail -s "Daily run of Registration Variance procedure results attached" adias@teladoc.com < ~/SCRIPTS/redmine_34325_daily.txt
   mail -s "Daily run of Registration Variance procedure results attached" ghochron@teladoc.com < ~/SCRIPTS/redmine_34325_daily.txt
   mail -s "Daily run of Registration Variance procedure results attached" suhrick@teladoc.com < ~/SCRIPTS/redmine_34325_daily.txt
fi
