# Helper functions


# Clone zabbix banch into specific directory.
#
# Arguments:
#   $1:  absolute path to directory where to clone zabbix branch
#   $2:  zabbix branch to clone, for example: release/6.4
#
clone_zabbix() {
    local directory="$1"
    local branch="$2"

    git clone --depth=1 --branch "$branch" https://git.zabbix.com/scm/zbx/zabbix.git "$directory"
    # To pull history run: git fetch --unshallow
}

# Build server, make database schema
#
# Arguments:
#   $1:  server sources directory
#
build_server() {
    local src_dir="$1"

    cd $src_dir
    ./bootstrap.sh
    ./configure --with-mysql --with-libcurl --enable-server --prefix=$src_dir

    # Add zabbix_server.conf file
}

# Create database, will drop existing database. Runs make dbschema before import.
#
# Arguments:
#   $1:  server sources directory with .sql files
#   $2:  database name to create
#   $3:  database connection string
#
create_database() {
    local sql_dir="$1"
    local database="$2"
    local connection_string="$3"

    cd $sql_dir
    make dbschema

    mysql $connection_string -e"DROP DATABASE IF EXISTS \`$database\`;"
    mysql $connection_string -e"CREATE DATABASE \`$database\` CHARACTER SET utf8 COLLATE utf8_bin;"
    mysql $connection_string $database < database/mysql/schema.sql
    mysql $connection_string $database < database/mysql/images.sql
    mysql $connection_string $database < database/mysql/data.sql
}

# Add .htaccess file with php settings suitable for zabbix frontend.
# Add index.php file with phpinfo.
#
# Arguments:
#   $1:  abosulte path to directory where to add .htaccess file
#
add_web_files() {
    local directory="$1"
    local branch="$1"

    echo -e "Options +Indexes\nphp_value post_max_size 16M\nphp_value max_execution_time 0" > "$directory/.htaccess"
    echo "<?php phpinfo();" > "$directory/phpinfo.php"
    ln -s "$work_dir" "$directory/ui/modules/dev-module"

    cp "$script_dir/zabbix.conf.php" "$zabbix_dir/ui/conf/zabbix.conf.php"
    sed -i -e "s/\{ZBX_DATABASE}/$branch/" "$directory/ui/conf/zabbix.conf.php"
    sed -i -e "s/\{ZBX_SERVER_PORT}/10051/" "$directory/ui/conf/zabbix.conf.php"
}

# List remote branches on git.zabbix.com. Only release branches greater or equal release/5.0 are listed.
#
# Returns:
#   Branch without "release/" prefix selected by user
#
select_branch() {
    gum choose $(git ls-remote --heads https://git.zabbix.com/scm/zbx/zabbix.git | grep -Po "(?<=refs/heads/release/)\S+" | awk -F'.' '$2 ~ /^[0-9]+$/ && ($1 + 0.0) >= 5.0 {print $1 "." $2}') master
}

# Checkout Zabbix branch.
#
# Arguments:
#   $1:  directory to clone directory to
#   $2:  zabbix branch to clone, branch name should be without "release/" prefix. example: 5.0 6.4 master
#
checkout_branch() {
    local directory="$1"
    local branch="$([ "$2" != "master" ] && echo "release/$2" || echo "$2")"

    clone_zabbix "$directory" "$branch"
}