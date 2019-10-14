cd /data/mysql
mv -f db1b-slow.log db1b-slow.log.x
mysql -e "flush logs;"
cat db1b-slow.log.historical db1b-slow.log.x > db1b-slow.log.historical.x
mv -f db1b-slow.log.historical.x db1b-slow.log.historical
slow_count=`grep Query_time db1b-slow.log.x | wc -l`
if [ "$slow_count" -gt 650 ]; then
mail -s "Alert - Slow Queries / Hour in db1 = $slow_count, Exceeds Threshold"  suhrick@teladoc.com </dev/null
mail -s "Alert - Slow Queries / Hour in db1 = $slow_count, Exceeds Threshold"  raghu@teladoc.com </dev/null
mail -s "Alert - Slow Queries / Hour in db1 = $slow_count, Exceeds Threshold"  hrancic@teladoc.com </dev/null
mail -s "Alert - Slow Queries / Hour in db1 = $slow_count, Exceeds Threshold"  adias@teladoc.com </dev/null
mail -s "Alert - Slow Queries / Hour in db1 = $slow_count, Exceeds Threshold"  kweinberg@teladoc.com </dev/null
fi
rm -f db1b-slow.log.x
echo `date` $slow_count >> /data/mysql/track_slow_counts.txt
