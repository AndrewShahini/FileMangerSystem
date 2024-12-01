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

clear

main_menu() {
    echo -e "${CYAN}=================================="
    echo -e "        UNIX Management Tool"
    echo -e "==================================${WHITE}"
    PS3="Please select a choice: "
    select choice in "System Status" "Backup" "Network" "Services" "User Management" "File Management" "Exit"
    do
        case $choice in
            "System Status") 
            system_status
                ;;
            "Backup") 
            backup
                ;;
            "Network") 
            network 
                ;;
            "Services") 
            services 
                ;;
            "User Management") 
            user_management  
                ;;
            "File Management") 
            file_management 
                ;;
            "Exit") 
            echo -e "${GREEN}Exiting...${WHITE}"; exit 0 
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
            "Check Memory Status") 
            free -h 
                ;;
            "Check CPU Temperature") 
                if command -v sensors &> /dev/null; then
                    temp=$(sensors | awk '/^temp1:/{print $2}' | tr -d '+°C')
                    echo "CPU Temperature: $temp°C"
                    if (( $(echo "$temp > 70" | bc -l) )) ; then
                        echo -e "{${RED}Warning: CPU temperature exceeds safe limit! ${WHITE}"
                        for i in { 1..4 }
                        do
                            speaker-test -t sine -f 1100 -l 1 & sleep .2 && kill -9 $!
                        done
                    fi
                else
                    echo "The 'sensors' command is not available. Please install 'lm-sensors'."
                fi
                ;;
            "List Active Processes") 
            ps aux 
               ;;
            "Stop a Process") 
                read -p "Enter PID of process to stop: " pid
                if ps -p $pid > /dev/null; then
                    kill $pid
                    echo "Process $pid stopped."
                else
                    echo "Invalid PID. Process not found."
                fi
                ;;
            "Back to Main Menu") 
	    	main_menu
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
                if [ ! -e "$file_path" ]; then
                    echo "File path does not exist."
                    continue
                fi
                read -p "Enter backup destination: " backup_dest
                if [ ! -d "$backup_dest" ]; then
                    echo "Backup destination does not exist."
                    continue
                fi
                read -p "Enter day of week for backup (0-6, Sun=0): " day
                read -p "Enter hour (0-23) for backup: " hour
                read -p "Enter minute (0-59) for backup: " minute

                cronjob="$minute $hour * * $day cp $file_path $backup_dest && echo \"$(date): Backup completed for $file_path\" >> ~/backup_log.txt"
                (crontab -l 2>/dev/null; echo "$cronjob") | crontab -
                echo "Backup scheduled."
                ;;
            "Show Last Backup Time") 
                if [ -f ~/backup_log.txt ]; then
                    tail -n 1 ~/backup_log.txt
                else
                    echo "No backup log found."
                fi
                ;;
            "Back to Main Menu") 
	    	main_menu
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
	       main_menu
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
            systemctl list-units --type=service
               ;;
            "Start a Service") 
            read -p "Enter service name to start: " service
                sudo systemctl start $service
                echo "$service started."
               ;;
            "Stop a Service") 
            read -p "Enter service name to stop: " service
                sudo systemctl stop $service
                echo "$service stopped."
               ;;
            "Back to Main Menu") 
	       main_menu
               ;;
            *) echo "Invalid option! Please select a number from the list." 
              ;;
        esac
    done
}

user_management() {
    echo -e "${LMAGENTA}User Management ${WHITE}"
    select user_choice in "Add User" "Give Root Permission to User" "Delete User" "Show Connected Users" "Show User Groups" "Disconnect Remote User" "Change User Group" "Back to Main Menu"
    do
        case $user_choice in
            "Add User")
		read -p "Enter the username for your new user: " username
		if id "$username" $>/dev/null; then
		    echo "The username $username already exists"
		else
		    sudo useradd -m $username
		    sudo passwd $username
		fi
		;;
	    "Give Root Permission to User")
		read -p "Enter the username to give permission to: " username
		if id "$username" &>/dev/null; then
		    sudo usermod -a -G root $username
		else
		    echo "User $username does not exist"
		fi
		;;
            "Delete User")
                read -p "Enter username to delete: " username
                if id "$username" &>/dev/null; then
                    sudo deluser $username
                else
                    echo "User $username does not exist."
                fi
                ;;
            "Show Connected Users")
		echo "Showing connected users"
		who
                ;;
            "Show User Groups")
                read -p "Enter username to list groups: " username
                if id "$username" &>/dev/null; then
                    groups $username
                else
                    echo "User $username does not exist."
                fi
                ;;
            "Disconnect Remote User")
		read -p "Enter username to disconnect: " username
		if who | grep -q "$username"; then
		    terminal=$(who | awk '$1 == "username" { print $2 }')
		    sudo pkill -t "$terminal"
		else
		    echo "The remote user $username is not currently connected"
		fi
                ;;
            "Change User Group")
		read -p "Enter the username to have group changed: " username
		if id "$username" $>/dev/null; then
		    read -p "Enter the group name to change to: " groupname
			if id "$groupname" $>/dev/null; then
			    sudo usermod -g $groupname $username
			else
			    echo "Group $groupname does not exist."
			fi
		else
		    echo "User $username does not exist."
		fi
                ;;
            "Back to Main Menu")
	    	main_menu
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
		read -p "Enter username of file's location: " username
		cd $username
		if [ $? -eq 0 ]; then
		    read -p "Enter the name of the file: " filename
		    if [ -e filename ]; then
			realpath $filename
		    else
			echo "File $filename does not exist."
		    fi
		else
		    echo "User $username does not exist."
		fi
                ;;
            "Show 10 Largest Files")
		echo "Displaying your 10 largest files..."
		ls -lS | head
                ;;
            "Show 10 Oldest Files")
		echo "Dislaying your 10 oldest files..."
		ls -lt | tail
                ;;
            "Send File via Email")
		read -p "Enter file to be sent by email: " filename
		if [ -e "$filename" ]; then
		    read -p "Enter the email of the recipient: " email
		    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
			read -p "Are you sure you want to send $filename to $email? [y/n]: " answer
			if [[ "$answer" == [yY] ]]; then
			    ATTACHMENT=$(realpath "$filename")
			    echo "Email sent from Bash." | mailx -s "$filename Attached" -A "ATTACHMENT" "$email"
			    if [ $? -eq 0 ]; then
				echo "Email sent successfully."
			    else
				echo "Email failed to send."
			    fi
			else
			    echo "Email will not be sent."
			fi
		    else
			echo "The email $email is not a valid email."
		    fi
		else
		    echo "The file $filename does not exist in the directory $(pwd)."
      		fi
                ;;
            "Back to Main Menu") 
	    	main_menu 
                ;;
            *) echo "Invalid option! Please select a number from the list." 
                ;;
        esac
    done
}

main_menu 
