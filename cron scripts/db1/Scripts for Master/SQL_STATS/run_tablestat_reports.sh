cd ~/SCRIPTS/SQL_STATS

mysql -t < tablestat_eds_read.sql > tablestat_eds_read.txt
mysql -t < tablestat_eds_changed.sql > tablestat_eds_changed.txt
mysql -t < tablestat_eds_read_pct.sql > tablestat_eds_read_pct.txt
mysql -t < tablestat_eds_changed_pct.sql > tablestat_eds_changed_pct.txt

echo "Report for" `date -I` > Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   Teladoc_eds Table Statistics Ordered by Rows_Read  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_eds_read.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   Teladoc_eds Table Statistics Ordered by Rows_Changed  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_eds_changed.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   Teladoc_eds Table Statistics Ordered by Pct Change in Rows Read  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_eds_read_pct.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   Teladoc_eds Table Statistics Ordered by Pct Change in Rows Changed  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_eds_changed_pct.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt

sed 's/$/\r/' Tablestat_Report.txt > x
mv x Tablestat_Report.txt
#mail -s "Teladoc_eds Table Statistics Report" -a  ~/SCRIPTS/SQL_STATS/Tablestat_Report.txt suhrick@teladoc.com  <  ~/SCRIPTS/SQL_STATS/tablestat_eds_boilerplate.txt
mail -s "Teladoc_eds Table Statistics Report" -a  ~/SCRIPTS/SQL_STATS/Tablestat_Report.txt  database-performance-reports@teladoc.com <  ~/SCRIPTS/SQL_STATS/tablestat_eds_boilerplate.txt

mysql -t < tablestat_erx_read.sql > tablestat_erx_read.txt
mysql -t < tablestat_erx_changed.sql > tablestat_erx_changed.txt
mysql -t < tablestat_erx_read_pct.sql > tablestat_erx_read_pct.txt
mysql -t < tablestat_erx_changed_pct.sql > tablestat_erx_changed_pct.txt


echo "Report for" `date -I` > Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
echo '++++++++   ERX Table Statistics Ordered by Rows_Read  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_erx_read.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   ERX Table Statistics Ordered by Rows_Changed  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_erx_changed.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   ERX Table Statistics Ordered by Pct Change in Rows Read  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_erx_read_pct.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo '++++++++   ERX Table Statistics Ordered by Pct Change in Rows Changed  ++++++++'  >> Tablestat_Report.txt
echo ' ' >> Tablestat_Report.txt
cat tablestat_erx_changed_pct.txt >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt
echo ' '  >> Tablestat_Report.txt

sed 's/$/\r/' Tablestat_Report.txt > x
mv x Tablestat_Report.txt

#mail -s "ERX Table Statistics Report" -a  ~/SCRIPTS/SQL_STATS/Tablestat_Report.txt suhrick@teladoc.com  <  ~/SCRIPTS/SQL_STATS/tablestat_erx_boilerplate.txt
mail -s "ERX Table Statistics Report" -a  ~/SCRIPTS/SQL_STATS/Tablestat_Report.txt database-performance-reports@teladoc.com  <  ~/SCRIPTS/SQL_STATS/tablestat_erx_boilerplate.txt

mysql < archive_table_stats.sql
