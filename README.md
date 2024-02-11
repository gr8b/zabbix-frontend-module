## Initialization

Git credentials should be set globally on host machine. When not set will required to configure in container console.

```sh
git config --global user.name username
git config --global user.email email@example.com
```

```sh
cd zabbix
./bootstrap.sh
./configure --with-mysql --with-libcurl --enable-server --prefix=$(pwd)
make dbschema
DB_NAME="zabbix" DB_ARGS="-h 127.0.0.1 -uroot -pmariadb" && \
    mysql $DB_ARGS -e"DROP DATABASE IF EXISTS \`$DB_NAME\`;" && \
    mysql $DB_ARGS -e"CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_bin;" && \
    mysql $DB_ARGS $DB_NAME < database/mysql/schema.sql && \
    mysql $DB_ARGS $DB_NAME < database/mysql/images.sql && \
    mysql $DB_ARGS $DB_NAME < database/mysql/data.sql

cd ../
ln -s $(pwd)/src $(pwd)/zabbix/ui/modules/module
```

## Todo

- (+) start `install.sh` script only when container is created for first time
- checkout Zabbix branch to it own folder named by branch name in `/var/www/html`.
- create module boilerplate if `manifest.json` is not present
- if `manifest.json` is present use it version to filter out list of Zabbix branch allowed to checkout
- generate IDE helper file `ide.helper.php`
- init database and `conf/zabbix.conf.php` file
- add start/stop Zabbix server helper, make it as module copied during installation or `.bashrc` helper
