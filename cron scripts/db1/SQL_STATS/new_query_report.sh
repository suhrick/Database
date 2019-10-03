rm ~/SCRIPTS/SQL_STATS/new_query_report.txt
mysql -t < ~/SCRIPTS/SQL_STATS/new_query_report.sql >  ~/SCRIPTS/SQL_STATS/new_query_report.txt
echo -e '\n' >> ~/SCRIPTS/SQL_STATS/new_query_report.txt
mysql  < ~/SCRIPTS/SQL_STATS/new_query_report_queries.sql >>  ~/SCRIPTS/SQL_STATS/new_query_report.txt
#mail -s "New SQL Report, db1" -a  ~/SCRIPTS/SQL_STATS/new_query_report.txt suhrick@teladoc.com < ~/SCRIPTS/SQL_STATS/new_query_report_boilerplate.txt
mail -s "New SQL Report, db1" -a  ~/SCRIPTS/SQL_STATS/new_query_report.txt database-performance-reports@teladoc.com < ~/SCRIPTS/SQL_STATS/new_query_report_boilerplate.txt
