find /var/lib/mysql -type f -name '*' -exec chmod 600 {} \;
find /var/lib/mysql -type f -name '*.sh' -exec chmod 700 {} \;
