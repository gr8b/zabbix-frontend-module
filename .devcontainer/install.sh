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

if [ -f "$work_dir/manifest.json" ]; then
    manifest_version=$(jq -r '.manifest_version' "$work_dir/manifest.json")

    if [ "${manifest_version:0:1}" = "2" ]; then
        select_branch "6.4" ""
    else
        select_branch "5.0" "6.2"
    fi
else
    echo "Select $(gum style --foreground "#f00" "Zabbix") version:"
    while [[ -z "$branch" ]]; do
        branch=$(select_branch "5.0" "")
    done

    echo "Adding module boilerplate files."
    if awk -v var="$your_variable" 'BEGIN { if (var >= 6.4 || var == "master") exit 0; else exit 1 }'; then
        generate_boilerplate "$work_dir" "2"
    else
        generate_boilerplate "$work_dir" "1"
    fi
fi

echo "Clone $(gum style --foreground "#f00" "Zabbix $branch")"
rm -rf "$zabbix_dir"
checkout_branch "$zabbix_dir" "$branch"

echo "Creating .htaccess and index.php files for $branch"
generate_web_files "$zabbix_dir" "$branch"

echo "Build server and database schema"
build_server "$zabbix_dir"

echo "Create database $branch"
create_database "$zabbix_dir" "$branch" "-h 127.0.0.1 -uroot -pmariadb"

echo "$(gum style --foreground "#0f0" "Done")"