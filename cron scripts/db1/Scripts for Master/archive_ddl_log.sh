cat ~/SCRIPTS/DDL.txt.old ~/SCRIPTS/DDL.txt > ~/SCRIPTS/x
mv ~/SCRIPTS/x ~/SCRIPTS/DDL.txt.old
echo "" > ~/SCRIPTS/DDL.txt
chmod 600 DDL.txt.old DDL.txt
