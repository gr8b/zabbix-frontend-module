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
    ./configure --silent --with-mysql --with-libcurl --enable-server --prefix=$src_dir

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
    make dbschema --silent

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
#   $2:  branch name, without "release/" prefix
#
generate_web_files() {
    local dir="$1"
    local branch="$2"
    local port="10051"

    echo -e "Options +Indexes\nphp_value post_max_size 16M\nphp_value max_execution_time 0" > "$dir/.htaccess"
    echo "<?php phpinfo();" > "$dir/phpinfo.php"
    ln -s "$work_dir" "$dir/ui/modules/dev-module"

    cp "$script_dir/zabbix.conf.php" "$zabbix_dir/ui/conf/zabbix.conf.php"
    sed -i -e "s|{ZBX_DATABASE}|$branch|" "$dir/ui/conf/zabbix.conf.php"
    sed -i -e "s|{ZBX_SERVER_PORT}|$port|" "$dir/ui/conf/zabbix.conf.php"
}

# Generate module boilerplate files: Module.php, manifest.json
#
# Arguments:
#   $1:   module directory
#   $2:   manifest version: 1, 2
#
generate_boilerplate() {
    local dir="$1"
    local manifest_version="$2"
    local json=$(cat "$script_dir/boilerplate/manifest.json")

    echo "Updating manifest.json properties:"
    local id=$(gum input --prompt "Module id: " --placeholder $(jq -r ".id" "$dir/manifest.json"))
    local namespace=$(gum input --prompt "Module namespace: " --placeholder $(jq -r ".namespace" "$dir/manifest.json"))

    json=$(echo "$json" | jq --arg val "$manifest_version" '.manifest_version=$val')

    if [ -n "$id" ]; then
        json=$(echo "$json" | jq --arg val "$id" '.id=$val')
    fi

    if [ -n "$namespace" ]; then
        json=$(echo "$json" | jq --arg val "$namespace" '.namespace=$val')
    fi

    echo "$json" | jq '.' > "$dir/manifest.json"
    cp "$script_dir/boilerplate/Module.php" "$dir"
    sed -i -e "s|{ZBX_NAMESPACE}|$namespace|" "$dir/Module.php"

    mkdir -p "$dir/actions"
    mkdir -p "$dir/views"
}

# List remote branches on git.zabbix.com.
#
# Arguments:
#   $1:   branch minimal version, inclusive, ignored when set to empty string.
#   $2:   branch maximal version, inclusive, ignored when set to empty string.
#
# Returns:
#   Branch without "release/" prefix selected by user
#
select_branch() {
    local min_version="$1"
    local max_version="$2"

    gum choose $(git ls-remote --heads https://git.zabbix.com/scm/zbx/zabbix.git \
        | grep -Po "(?<=refs/heads/release/)\S+" \
        | awk -F'.' \
            -v max_version="$max_version" \
            -v min_version="$min_version" \
            '$2 ~ /^[0-9]+$/ \
            && (!min_version || ($1 "." $2) >= min_version) \
            && (!max_version || ($1 "." $2) <= max_version) \
            {print $1 "." $2}' \
        ) $(awk -v max_version="$max_version" 'BEGIN { if (!max_version || max_version >= 6.4) print "master"; else print "" }')
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