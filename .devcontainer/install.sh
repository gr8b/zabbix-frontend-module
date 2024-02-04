#!/bin/bash

export GUM_CHOOSE_CURSOR=" "

clone_zabbix() {
    local directory="$1"
    local branch="$2"

    cd "$directory"
    git init
    git remote add origin https://git.zabbix.com/scm/zbx/zabbix.git
    git fetch --depth=1 origin "$branch"
    git reset --hard "origin/$branch"
}

init_frontend() {
    local directory="$1"
    local file_content=$(cat <<EOL
php_value post_max_size 16M
php_value max_execution_time 0
EOL
)

    echo -e "$file_content" > "$directory/.htaccess"
}


select_branch() {
    gum choose $(git ls-remote --heads https://git.zabbix.com/scm/zbx/zabbix.git | grep -Po "(?<=refs/heads/release/)\S+" | awk -F'.' '$2 ~ /^[0-9]+$/ && ($1 + 0.0) >= 5.0 {print $1 "." $2}')
}

checkout_branch() {
    echo "Select $(gum style --foreground "#f00" "Zabbix") version:"
    zabbix_branch=$(select_branch)

    # if [ zabbix_branch]
}


select_branch