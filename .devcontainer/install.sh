#!/bin/bash

# Exit the script if any command fails
set -e

if ! type -P gum &>/dev/null; then
    echo "Please install gum utility from https://github.com/charmbracelet/gum"
    exit 1
fi

export GUM_CHOOSE_CURSOR=" "
export GUM_CHOOSE_CURSOR_FOREGROUND="#f00"

work_dir=$(pwd)
zabbix_dir="/var/www/html"
script_dir="$(dirname "$0")"

source "$script_dir/install.src.sh"

# TODO: check if manifest.json file exists and contains "zabbix" key, use it as branch name to checkout
echo "Select $(gum style --foreground "#f00" "Zabbix") version:"
while [[ -z "$branch" ]]; do
    branch=$(select_branch)
done

echo "Clone $(gum style --foreground "#f00" "Zabbix $branch")"
checkout_branch "$zabbix_dir" "$branch"

echo "Creating .htaccess and index.php files for $branch"
add_web_files "$zabbix_dir" "$branch"

echo "Build server and database schema"
build_server "$zabbix_dir"

echo "Create database $branch"
create_database "$zabbix_dir" "$branch" "-h 127.0.0.1 -uroot -pmariadb"
