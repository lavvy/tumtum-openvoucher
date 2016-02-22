#!/bin/bash


VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

# my little hack

wget -O /tmp/package.tar.gz ${PACKAGE_URL}
tar -zxf /tmp/package.tar.gz -C /tmp/
cp -pr /tmp/OpenVoucher-*/src/* /app/
rm -rf /app/.htaccess
#creating mysql database
mysql -uroot -e "CREATE USER 'local'@'%' IDENTIFIED BY 'local'"     
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'openvoucher'@'%' WITH GRANT OPTION"                                                                            
mysql -uopenvoucher -popenvoucher </tmp/OpenVoucher-*/database/tables.sql


exec supervisord -n


