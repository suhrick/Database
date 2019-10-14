##### initialize output file as a file containing "diff" output with ;
#touch  ~/SCRIPTS/DDL.txt
#grep -E -i 'alter |drop |create ' /data/mysql/server_audit.log | grep -v -i 'show '| grep -v -i 'create user' | diff ~/SCRIPTS/DDL.txt - > x
#mv x  ~/SCRIPTS/DDL.txt
#########################################################################################
cd  ~/SCRIPTS
# extract all DDL statements from previous and current audit log, place in "x"
grep -E -i "'alter |'drop |'create |'rename " /data/mysql/server_audit.log.001 | grep -v -i 'show '| grep -v -i 'create user' | grep -v -i 'drop user' | grep -v -i ' temporary ' > x
grep -E -i "'alter |'drop |'create |'rename " /data/mysql/server_audit.log | grep -v -i 'show '| grep -v -i 'create user' | grep -v -i 'drop user' | grep -v -i ' temporary ' >> x
# Compare "x" to the audit history log.  New statements should found and placed in "y".
grep -F -x -v -f ~/SCRIPTS/DDL.txt x > y
# Append to DDL history log
cat ~/SCRIPTS/DDL.txt y > x
mv  x ~/SCRIPTS/DDL.txt
rm y
chmod 600 ~/SCRIPTS/DDL.txt
