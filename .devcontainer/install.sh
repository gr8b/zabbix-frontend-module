#!/bin/bash

export GUM_CHOOSE_CURSOR=" "
export GUM_CHOOSE_CURSOR_FOREGROUND="#f00"


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
}

# Add .htaccess file with php settings suitable for zabbix frontend.
# Add index.php file with phpinfo.
#
# Arguments:
#   $1:  abosulte path to directory where to add .htaccess file
#
add_web_files() {
    local directory="$1"

    echo -e "$(cat <<EOL
Options +Indexes
php_value post_max_size 16M
php_value max_execution_time 0
EOL
)" > "$directory/.htaccess"

    echo -e "<?php phpinfo();" > "$directory/index.php"
}

# List remote branches on git.zabbix.com. Only release branches greater or equal release/5.0 are listed.
#
# Returns:
#   Branch without "release/" prefix selected by user
#
select_branch() {
    echo "Select $(gum style --foreground "#f00" "Zabbix") version:"
    gum choose $(git ls-remote --heads https://git.zabbix.com/scm/zbx/zabbix.git | grep -Po "(?<=refs/heads/release/)\S+" | awk -F'.' '$2 ~ /^[0-9]+$/ && ($1 + 0.0) >= 5.0 {print $1 "." $2}') master
}

# $1  zabbix branch
checkout_branch() {
    zabbix_branch=$(select_branch)

    # if [ zabbix_branch]
}


selected=$(select_branch)
echo "Branch selected: $selected"