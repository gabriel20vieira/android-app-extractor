#!/bin/bash

application="$1"

if [ -z "$application" ]; then
    echo -e "\e[31mProvide an application.\e[0m"
    echo -e "\e[33mExiting\e[0m"
    exit 1
fi

echo -n "Extract: "
echo -e "\e[32m$application\e[0m"

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

function extract_data_from {
    path=$1
    
    timestamp=$(date +%Y%m%d%H%M%S)
    zip_name=${timestamp}.${path//\//.}${application}.tgz
    save_to="/sdcard/Download/${zip_name}"

    adb shell "su 0 tar -cvzf $save_to $path" >/dev/null
    adb pull $save_to >/dev/null
}

function extract_folder_exists {
    path=$1
    if adb shell "if test -d $path; then echo 'exist'; fi" | grep -q 'exist'; then
        return 0
    fi
    return 1
}

function extract_file_exists {
    path=$1
    if adb shell "if test -f $path; then echo 'exist'; fi" | grep -q 'exist'; then
        return 0
    fi
    return 1
}

function can_extract_permissions {
    path=$1
    if ! adb shell "su 0 ls $path | grep 'denied'" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

function extract_suite {
    location=$1
    can_extract=$(can_extract_permissions $location)
    exists_folder=$(extract_folder_exists $location)
    exists_file=$(extract_file_exists $location)
    
    echo ""
    echo -n "Object\t\t"
    echo $location
    echo -n "Exists\t\t"
    if [ $exists_folder -eq 0 ] || [ $exists_file -eq 0 ]; then
        echo -e "\e[32mYes\e[0m"
    else
        echo -e "\e[31mNo\e[0m"
    fi
    echo -n "Permission\t"
    if [ $can_extract -eq 0 ]; then
        echo -e "\e[32mYes\e[0m"
    else
        echo -e "\e[31mNo\e[0m"
    fi

    if [ $exists_folder -eq 0 ] || [ $exists_file -eq 0 ]; then
        if [ $can_extract -eq 0 ]; then
            extract_data_from $location
        fi
    fi

    echo -n "Extracted\t"
    if [ $can_extract -eq 0 ]; then
        echo -e "\e[32mYes\e[0m"
    else
        echo -e "\e[31mNo\e[0m"
    fi
}

adb_exec="adb"

if test_command_exists $adb_exec; then
    echo -n "ADB Exists: "
    echo -e "\e[32mYes\e[0m"
    echo -e "Script will always use the first device in adb, make sure only one is active.\nEnter to continue..."
    wait_enter_key

    echo -n "Application installed on device: "
    if ! adb shell cmd package list packages | grep -q $application; then
        echo -e "\e[31mNo\e[0m"
        echo -e "\e[33mExiting\e[0m"
        exit 1
    else
        echo -e "\e[32mYes\e[0m"
    fi

    echo "Starting extraction ..."

    extract_suite "/data/data/$application/"
    extract_suite "/data/user_de/0/$application/"
    extract_suite "/data/user/0/$application/"
    
    base_apk=$(adb shell "su 0 find /data/app/ | grep $application | grep base.apk")
    if [ ! -z "$base_apk" ]; then
        extract_suite $base_apk
    fi
else
    echo -n "ADB Exists: "
    echo -e "\e[31mNo\e[0m"
    echo "'$adb_exec' does not exist. Please install it on the machine or check the environment variables."
fi
