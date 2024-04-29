#!/bin/bash

application="$1"

if [ -z "$application" ]; then
    echo -e "\e[91mProvide an application.\e[0m"
    echo -e "\e[33mExiting\e[0m"
    exit 1
fi

echo -n "Extract: "
echo -e "\e[92m$application\e[0m"

test_command_exists() {
    local command="$1"
    if command -v "$command" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

wait_enter_key() {
    while true; do
        read -n 1 -s -r -p "Press enter to continue..."
        echo ""
        break
    done
}

extract_data_from() {
    local path="$1"
    app_path="$path/$application/"
    timestamp=$(date +"%Y%m%d%H%M%S")
    zip_name="$timestamp.${path//\//.}$application.tgz"
    save_to="/sdcard/Download/$zip_name"

    adb shell "su 0 tar -cvzf $save_to $app_path" &>/dev/null
    adb pull "$save_to" &>/dev/null
}

extract_folder_exists() {
    local path="$1"
    if adb shell "[ -d \"$path\" ]"; then
        return 0
    else
        return 1
    fi
}

can_extract_permissions() {
    local path="$1"
    if ! adb shell "su 0 ls \"$path\" | grep 'denied'"; then
        return 0
    else
        return 1
    fi
}

extract_suite() {
    local location="$1"
    extractFolder="$location"
    canExtract=$(can_extract_permissions "$extractFolder")
    folderExists=$(extract_folder_exists "$extractFolder")
    
    echo ""
    echo -n "Folder"$'\t\t'
    echo "$extractFolder"
    echo -n "Exists"$'\t\t'
    if [ "$folderExists" -eq 0 ]; then echo -e "\e[92mYes\e[0m"; else echo -e "\e[91mNo\e[0m"; fi
    echo -n "Permission"$'\t'
    if [ "$canExtract" -eq 0 ]; then echo -e "\e[92mYes\e[0m"; else echo -e "\e[91mNo\e[0m"; fi

    extract_data_from "$extractFolder"

    echo -n "Extracted"$'\t'
    if [ "$canExtract" -eq 0 ]; then echo -e "\e[92mYes\e[0m"; else echo -e "\e[91mNo\e[0m"; fi
}

adb_exec="adb"

if test_command_exists "$adb_exec"; then
    echo -n "ADB Exists: "
    echo -e "\e[92mYes\e[0m"
    echo "Script will always use the first device in adb, make sure only one is active."
    wait_enter_key

    echo -n "Application installed on device: "
    if ! adb shell "cmd package list packages" | grep -q "$application"; then
        echo -e "\e[91mNo\e[0m"
        echo -e "\e[33mExiting\e[0m"
        exit 1
    else
        echo -e "\e[92mYes\e[0m"
    fi

    echo "Starting extraction ..."

    extract_suite "/data/data"
    extract_suite "/data/user_de/0"
    extract_suite "/data/user/0"

else
    echo -n "ADB Exists: "
    echo -e "\e[91mNo\e[0m"
    echo "'$adb_exec' does not exist. Please install it on the machine or check the environment variables."
fi
