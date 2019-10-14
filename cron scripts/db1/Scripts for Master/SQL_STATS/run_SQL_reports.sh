cd /var/lib/mysql/SCRIPTS/SQL_STATS
mysql run_stats < gather_final_stats.sql
mysql run_stats < report_by_executions.sql > report_by_executions.txt
mysql run_stats < report_by_total_rows.sql > report_by_total_rows.txt
mysql run_stats < report_by_total_time.sql > report_by_total_time.txt

echo '++++++++   Top SQL By Total Rows ++++++++'  > SQL_Report.txt
echo ' ' >> SQL_Report.txt
cat report_by_total_rows.txt >> SQL_Report.txt
echo ' '  >> SQL_Report.txt
echo ' '  >> SQL_Report.txt
echo ' '  >> SQL_Report.txt
echo  '++++++++   Top SQL By Executions   ++++++++' >>  SQL_Report.txt
echo ' ' >> SQL_Report.txt
cat report_by_executions.txt >> SQL_Report.txt
echo ' '  >> SQL_Report.txt
echo ' '  >> SQL_Report.txt
echo ' '  >> SQL_Report.txt
echo  '++++++++   Top SQL By Total Time   ++++++++' >> SQL_Report.txt
echo ' ' >> SQL_Report.txt
cat report_by_total_time.txt  >> SQL_Report.txt
mail -s "Top SQL Report, db1"  database-performance-reports@teladoc.com  <  /var/lib/mysql/SCRIPTS/SQL_STATS/SQL_Report.txt
mysql run_stats < initialize_tables.sql
