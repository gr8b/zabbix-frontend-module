#!/bin/bash

if ! type -P gum &>/dev/null; then
    echo "Please install gum utility from https://github.com/charmbracelet/gum"
    exit 1
fi

export GUM_CHOOSE_CURSOR=" "
export GUM_CHOOSE_CURSOR_FOREGROUND="#f00"

echo $(pwd)

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

# Add .htaccess file with php settings suitable for zabbix frontend.
# Add index.php file with phpinfo.
#
# Arguments:
#   $1:  abosulte path to directory where to add .htaccess file
#
add_web_files() {
    local directory="$1"

    echo -e "Options +Indexes\nphp_value post_max_size 16M\nphp_value max_execution_time 0" > "$directory/.htaccess"
    echo "<?php phpinfo();" > "$directory/index.php"
    ln -s
}

# List remote branches on git.zabbix.com. Only release branches greater or equal release/5.0 are listed.
#
# Returns:
#   Branch without "release/" prefix selected by user
#
select_branch() {
    gum choose $(git ls-remote --heads https://git.zabbix.com/scm/zbx/zabbix.git | grep -Po "(?<=refs/heads/release/)\S+" | awk -F'.' '$2 ~ /^[0-9]+$/ && ($1 + 0.0) >= 5.0 {print $1 "." $2}') master
}

# $1:
# $2:  zabbix branch
checkout_branch() {
    local directory="$1"
    local branch="$([ "$2" != "master" ] && echo "release/$2" || echo "$2")"

    clone_zabbix "$directory" "$branch"
}

# TODO: check if manifest.json file exists and contains "zabbix" key, use it as branch name to checkout
echo "Select $(gum style --foreground "#f00" "Zabbix") version:"
while [[ -z "$branch" ]]; do
    branch=$(select_branch)
done

echo "Git clone $(gum style --foreground "#f00" "Zabbix $branch")"
checkout_branch "$HOME/zabbix" "$branch"

add_web_files "$HOME/zabbix"
