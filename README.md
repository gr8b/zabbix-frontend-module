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