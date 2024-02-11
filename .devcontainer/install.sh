#!/bin/bash

if ! type -P gum &>/dev/null; then
    echo "Please install gum utility from https://github.com/charmbracelet/gum"
    exit 1
fi

export GUM_CHOOSE_CURSOR=" "
export GUM_CHOOSE_CURSOR_FOREGROUND="#f00"

workdir=$(pwd)
zabbixdir="/var/www/html"

source "install.src.sh"

container_init

# TODO: check if manifest.json file exists and contains "zabbix" key, use it as branch name to checkout
echo "Select $(gum style --foreground "#f00" "Zabbix") version:"
while [[ -z "$branch" ]]; do
    branch=$(select_branch)
done

echo "Clone $(gum style --foreground "#f00" "Zabbix $branch")"
checkout_branch "$zabbixdir" "$branch"

echo "Creating .htaccess and index.php files"
add_web_files "$zabbixdir"
