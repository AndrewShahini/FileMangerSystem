#!/bin/bash

main_menu() {
    clear
    echo "UNIX Management Tool"

    select choice in "System Status" "Backup" "Network" "Services" "User Management" "File Management" "Exit"
    do
        case $REPLY in
            1) system_status 
                ;;
            2) backup 
                ;;
            3) network 
                ;;
            4) services 
                ;;
            5) user_management  
                ;;
            6) file_management 
                ;;
            7) echo -e "Exiting..."; exit 0 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

system_status() {
    echo "System Status"
    select sys_choice in "Check Memory Status" "Check CPU Temperature" "List Active Processes" "Stop a Process" "Back to Main Menu"
    do
        case $REPLY in
            1) free -h 
                ;;
            2) 
                if [ command -v sensors &> /dev/null ]
                then
                    temp=$(sensors | awk '/^temp1:/{print $2}' | tr -d '+°C')
                    echo "CPU Temperature: $temp°C"
                    if [ (( $(echo "$temp > 70" | bc -l) )) ]
                    then
                        echo "Warning: CPU temperature exceeds safe limit!"
                    fi
                else
                    echo "The 'sensors' command is not available. Please install 'lm-sensors'."
                fi
                ;;
            3) ps aux 
               ;;
            4) 
                read -p "Enter PID of process to stop: " pid
                if [ ps -p $pid > /dev/null ]
                then
                    kill $pid
                    echo "Process $pid stopped."
                else
                    echo "Invalid PID. Process not found."
                fi
                ;;
            5) return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

backup() {
    echo "Backup"
    select backup_choice in "Schedule a Backup" "Show Last Backup Time" "Back to Main Menu"
    do
        case $REPLY in
            1) 
                read -p "Enter the file path to backup: " file_path
                ;;
            2) 
                ;;
            3) return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

network() {
    echo "Network"
    select net_choice in "Show Network Details" "Enable/Disable Network Card" "Set IP Address" "List Wi-Fi Networks and Connect" "Back to Main Menu"
    do
        case $REPLY in
            1) 
                ;;
            2) 
                read -p "Enter interface name to enable/disable: " interface
                read -p "Enable (1) or Disable (2): " action
                ;;
            3) 
                read -p "Enter interface name: " interface
                read -p "Enter IP address to set (e.g., 192.168.1.10/24): " ip_address
                sudo ip addr add $ip_address dev $interface
                echo "IP address $ip_address set on $interface."
                ;;
            4) 
                ;;
            5) return 
               ;;
            *) echo "Invalid option! Please select a number from the list." 
              ;;
        esac
    done
}

services() {
    echo "Services"
    select serv_choice in "Show Services" "Start a Service" "Stop a Service" "Back to Main Menu"
    do
        case $REPLY in
            1) systemctl list-units --type=service 
               ;;
            2) 
               ;;
            3) 
               ;;
            4) return 
               ;;
            *) echo "Invalid option! Please select a number from the list." 
              ;;
        esac
    done
}

user_management() {
    echo "User Management"
    select user_choice in "Add User" "Delete User" "Show Connected Users" "Show User Groups" "Disconnect Remote User" "Change User Group" "Back to Main Menu"
    do
        case $REPLY in
            1) 
                ;;
            2) 
                read -p "Enter username to delete: " username
                if [ id "$username" &>/dev/null ]
                then
                    sudo deluser $username
                else
                    echo "User $username does not exist."
                fi
                ;;
            3) who 
                ;;
            4) 
                read -p "Enter username to list groups: " username
                if [ id "$username" &>/dev/null ]
                then
                    groups $username
                else
                    echo "User $username does not exist."
                fi
                ;;
            5)
                ;;
            6)
                ;;
            7) return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

file_management() {
    echo "File Management"
    select file_choice in "Search for a file in user’s directory" "Show 10 Largest Files" "Show 10 Oldest Files" "Send File via Email" "Back to Main Menu"
    do
        case $REPLY in
            1) 
                ;;
            2) 
                ;;
            3) 
                ;;
            4) 
                ;;
            5) return 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

main_menu
