#!/bin/bash
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
LMAGENTA='\033[1;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
ORANGE='\033[1;33m'


main_menu() {
    clear
    echo -e "${CYAN}UNIX Management Tool ${WHITE}"

    select choice in "System Status" "Backup" "Network" "Services" "User Management" "File Management" "Exit"
    do
        case $choice in
            "System Status") system_status 
                ;;
            "Backup") backup 
                ;;
            "Network") network 
                ;;
            "Services") services 
                ;;
            "User Management") user_management  
                ;;
            "File Management") file_management 
                ;;
            "Exit") echo -e "Exiting..."; exit 0 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

system_status() {
    echo -e "${MAGENTA}System Status ${WHITE}"
    select sys_choice in "Check Memory Status" "Check CPU Temperature" "List Active Processes" "Stop a Process" "Back to Main Menu"
    do
        case $sys_choice in
            "Check Memory Status") free -h 
                ;;
            "Check CPU Temperature") 
                if [ command -v sensors &> /dev/null ]
                then
                    temp=$(sensors | awk '/^temp1:/{print $2}' | tr -d '+°C')
                    echo "CPU Temperature: $temp°C"
                    if [ (( $(echo "$temp > 70" | bc -l) )) ]
                    then
                        echo -e "{${RED}Warning: CPU temperature exceeds safe limit! ${WHITE}"
                    fi
                else
                    echo "The 'sensors' command is not available. Please install 'lm-sensors'."
                fi
                ;;
            "List Active Processes") ps aux 
               ;;
            "Stop a Process") 
                read -p "Enter PID of process to stop: " pid
                if [ ps -p $pid > /dev/null ]
                then
                    kill $pid
                    echo "Process $pid stopped."
                else
                    echo "Invalid PID. Process not found."
                fi
                ;;
            "Back to Main Menu") return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

backup() {
    echo -e "${BLUE}Backup ${WHITE}"
    select backup_choice in "Schedule a Backup" "Show Last Backup Time" "Back to Main Menu"
    do
        case $backup_choice in
            "Schedule a Backup") 
                read -p "Enter the file path to backup: " file_path
                ;;
            "Show Last Backup Time") 
                ;;
            "Back to Main Menu") 
                return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

network() {
    echo -e "${YELLOW}Network ${WHITE}"
    select net_choice in "Show Network Details" "Enable/Disable Network Card" "Set IP Address" "List Wi-Fi Networks and Connect" "Back to Main Menu"
    do
        case $net_choice in
            "Show Network Details") 
                ;;
            "Enable/Disable Network Card") 
                ;;
            "Set IP Address") 
                ;;
            "List Wi-Fi Networks and Connect") 
                ;;
            "Back to Main Menu")
               return 
               ;;
            *) echo "Invalid option! Please select a number from the list." 
              ;;
        esac
    done
}

services() {
    echo -e "${GREEN}Services ${WHITE}"
    select serv_choice in "Show Services" "Start a Service" "Stop a Service" "Back to Main Menu"
    do
        case $serv_choice in
            "Show Services") 
               ;;
            "Start a Service") 
               ;;
            "Stop a Service") 
               ;;
            "Back to Main Menu") 
               return 
               ;;
            *) echo "Invalid option! Please select a number from the list." 
              ;;
        esac
    done
}

user_management() {
    echo -e "${LMAGENTA}User Management ${WHITE}"
    select user_choice in "Add User" "Delete User" "Show Connected Users" "Show User Groups" "Disconnect Remote User" "Change User Group" "Back to Main Menu"
    do
        case $user_choice in
            "Add User") 
                ;;
            "Delete User") 
                read -p "Enter username to delete: " username
                if [ id "$username" &>/dev/null ]
                then
                    sudo deluser $username
                else
                    echo "User $username does not exist."
                fi
                ;;
            "Show Connected Users") who 
                ;;
            "Show User Groups") 
                read -p "Enter username to list groups: " username
                if [ id "$username" &>/dev/null ]
                then
                    groups $username
                else
                    echo "User $username does not exist."
                fi
                ;;
            "Disconnect Remote User")
                ;;
            "Change User Group")
                ;;
            "Back to Main Menu") 
                return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

file_management() {
    echo -e "${ORANGE}File Management ${WHITE}"
    select file_choice in "Search for a file in user’s directory" "Show 10 Largest Files" "Show 10 Oldest Files" "Send File via Email" "Back to Main Menu"
    do
        case $file_choice in
            "Search for a file in user’s directory") 
                ;;
            "Show 10 Largest Files") 
                ;;
            "Show 10 Oldest Files") 
                ;;
            "Send File via Email") 
                ;;
            "Back to Main Menu") 
                return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

main_menu
