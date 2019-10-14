cd ~/SCRIPTS
rm extract_users.txt
echo "db1 User Report as of " `date` > extract_users.txt
echo "Extraction query : " "select user, host, Select_priv, Create_user_priv, Insert_priv, Update_priv,Delete_priv,Drop_priv,Grant_priv,Super_priv from user order by user asc;" >> extract_users.txt
mysql -t < extract_users.sql >> extract_users.txt
mail -s "db1 Users Report" -a extract_users.txt suhrick@teladoc.com < extract_users_boilerplate.txt
mail -s "db1 Users Report" -a extract_users.txt raghu@teladoc.com < extract_users_boilerplate.txt
mail -s "db1 Users Report" -a extract_users.txt hrancic@teladoc.com < extract_users_boilerplate.txt
mail -s "db1 Users Report" -a extract_users.txt jmutuski@teladoc.com < extract_users_boilerplate.txt
mail -s "db1 Users Report" -a extract_users.txt adias@teladoc.com < extract_users_boilerplate.txt
