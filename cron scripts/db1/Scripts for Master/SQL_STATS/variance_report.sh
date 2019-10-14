rm ~/SCRIPTS/SQL_STATS/variance_report.txt
mysql -t < ~/SCRIPTS/SQL_STATS/variance_report.sql >  ~/SCRIPTS/SQL_STATS/variance_report.txt
echo -e '\n' >> ~/SCRIPTS/SQL_STATS/variance_report.txt
mysql  < ~/SCRIPTS/SQL_STATS/variance_report_queries.sql >>  ~/SCRIPTS/SQL_STATS/variance_report.txt
#mail -s "SQL Variance Report, db1" -a  ~/SCRIPTS/SQL_STATS/variance_report.txt database-performance-reports@teladoc.com  < ~/SCRIPTS/SQL_STATS/variance_report_boilerplate.txt
mail -s "SQL Variance Report, db1" -a  ~/SCRIPTS/SQL_STATS/variance_report.txt suhrick@teladoc.com  < ~/SCRIPTS/SQL_STATS/variance_report_boilerplate.txt
