#if ps -ef | grep binlogs | grep -v grep > /dev/null
#then
#  exit 1
#else
  find  /backup2/binlogs/* -ctime +4 | xargs rm -rf
  rm -f ~/SCRIPTS/bins.txt
  ls -tr /data/mysql/db1-master-bin.* > ~/SCRIPTS/bins.txt
  head -n -2 ~/SCRIPTS/bins.txt > ~/SCRIPTS/tmp.txt
  mv ~/SCRIPTS/tmp.txt ~/SCRIPTS/bins.txt
  rm -f ~/SCRIPTS/copy_these_binlogs.sh
  while read p; do
    echo  "cp -n "$p" /backup2/binlogs/" >> ~/SCRIPTS/copy_these_binlogs.sh
  done < ~/SCRIPTS/bins.txt
  chmod 777 ~/SCRIPTS/copy_these_binlogs.sh
  rm -f ~/SCRIPTS/bins.txt
  ~/SCRIPTS/copy_these_binlogs.sh
  if [ $? == 0 ]; then
      echo  ""
  else
      mail -s "db1a binlogs failed to move to off-server storage"  suhrick@teladoc.com </dev/null
      mail -s "db1a binlogs failed to move to off-server storage"  raghu@teladoc.com </dev/null
  fi

#fi

