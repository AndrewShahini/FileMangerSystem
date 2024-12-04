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
    echo -e "      UNIX Management Tool"
    echo -e "==================================${WHITE}"
    PS3=$(echo -e "${CYAN}Please select a choice: ${WHITE}")
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
            *) echo -e "${RED}Invalid option! Please select a number from the list.${WHITE}" 
                ;;
        esac
    done
}

system_status() {
    echo -e "${MAGENTA}System Status Menu${WHITE}"
    select sys_choice in "Check Memory Status" "Check CPU Temperature" "List Active Processes" "Stop a Process" "Back to Main Menu"
    do
        case $sys_choice in
            "Check Memory Status") 
            free -h 
	    echo -e "${BLUE} Returning to System Status Menu... ${WHITE}"
     	    ;;
            "Check CPU Temperature") 
                if command -v sensors &> /dev/null; then
                    temp=$(sensors | awk '/^temp1:/{print $2}' | tr -d '+°C')
                    echo "CPU Temperature: $temp°C"
                    if (( $(echo "$temp > 70" | bc -l) )) ; then
                        echo -e "${RED}Warning: CPU temperature exceeds safe limit! ${WHITE}"
                        for i in { 1..4 }
                        do
                            speaker-test -t sine -f 1100 -l 1 & sleep .2 && kill -9 $!
                        done
                    fi
                else
                    echo -e "${RED}The 'sensors' command is not available. Please install 'lm-sensors'.${WHITE}"
                fi
		echo -e "${BLUE} Returning to System Status Menu... ${WHITE}"
                ;;
            "List Active Processes") 
            	ps aux 
	    	echo -e "${BLUE} Returning to System Status Menu... ${WHITE}"
                ;;
            "Stop a Process") 
	    	ps aux | awk '{print $2, $11}'
                read -p "Enter PID of process to stop: " pid
                if ps -p $pid > /dev/null; then
                    kill $pid
                    echo -e "${ORANGE}Process $pid stopped.${WHITE}"
                else
                    echo -e "${RED}Invalid PID. Process not found.${WHITE}"
                fi
		echo -e "${BLUE} Returning to System Status Menu... ${WHITE}"
                ;;
            "Back to Main Menu") 
	    	main_menu
                ;;
            *) echo -e "${RED}Invalid option! Please select a number from the list.${WHITE}" 
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
                    echo -e "${RED}File path does not exist.${WHITE}"
                    continue
                fi
                read -p "Enter backup destination: " backup_dest
                if [ ! -d "$backup_dest" ]; then
                    echo -e "${RED}Backup destination does not exist.${WHITE}"
                    continue
                fi
                read -p "Enter day of week for backup (0-6, Sun=0): " day
                read -p "Enter hour (0-23) for backup: " hour
                read -p "Enter minute (0-59) for backup: " minute

                cronjob="$minute $hour * * $day cp $file_path $backup_dest && echo \"$(date): Backup completed for $file_path\" >> ~/backup_log.txt"
                (crontab -l 2>/dev/null; echo "$cronjob") | crontab -
                echo -e "${ORANGE}Backup scheduled. ${WHITE}"
		echo -e "${BLUE} Returning to Backup Menu... ${WHITE}"
                ;;
            "Show Last Backup Time") 
                if [ -f ~/backup_log.txt ]; then
                    tail -n 1 ~/backup_log.txt
                else
                    echo -e "${RED}No backup log found. ${WHITE}"
                fi
		echo -e "${BLUE}Returning to Backup Menu... ${WHITE}"
                ;;
            "Back to Main Menu") 
	    	echo -e "${BLUE}Returning to Backup Menu...${WHITE}"
	    	main_menu
                ;;
            *) echo -e "${RED}Invalid option! Please select a number from the list. ${WHITE}" 
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
	    	if command -v ip &> /dev/null; then
     			ip addr show
		else
  			ifconfig
     		fi
       		echo -e "${GREEN}Returning to Network Menu... ${WHITE}"
                ;;
            "Enable/Disable Network Card") 
	    	nmcli device status | awk '{print $1}'
	    	read -p "Enter interface name to enable/disable: " interface
      		read -p "Enable (1) or Disable (2): " action
		if [ "$action" -eq 1 ]; then
  			sudo ip link set $interface up
     			echo "$interface enabled"
       		elif [ "$action" -eq 2 ]; then
	 		sudo ip link set $interface down
    			echo "$interface disabled"
      		else
			echo -e "${RED}Invalid action selected.${WHITE}"
		fi
	  	echo -e "${GREEN}Returning to Network Menu...${WHITE}"
                ;;
            "Set IP Address") 
	    	nmcli device status | awk '{print $1}'
	    	read -p "Enter interface name: " interface
      		read -p "Enter IP address to set (e.g., 192.168.1.10/24): " ip_address
		sudo ip addr add $ip_address dev $interface
  			echo "IP address $ip_address set on $interface."
     		echo -e "${GREEN}Returning to Network Menu... ${WHITE}"
                ;;
            "List Wi-Fi Networks and Connect") 
	    	if command -v nmcli &> /dev/null; then
      			nmcli dev wifi list
	 	read -p "Enter SSID to connect:" ssid
      			nmcli dev wifi connect "$ssid"
	 	else
   			echo -e "${RED}The 'ncmli' command is not available. Please install 'NetworkManager'. ${WHITE}"
      		fi
		echo -e "${GREEN}Returning to Network Menu...${WHITE}"
                ;;
            "Back to Main Menu")
	    	echo -e "${GREEN}Returning to Network Menu...${WHITE}"
	       main_menu 
               ;;
            *) echo -e "${RED}Invalid option! Please select a number from the list.${WHITE}" 
              ;;
        esac
    done
}

services() {
    echo -e "${GREEN}Services Menu${WHITE}"
    select serv_choice in "Show Services" "Start a Service" "Stop a Service" "Back to Main Menu"
    do
        case $serv_choice in
            "Show Services") 
            systemctl list-units --type=service
	    echo -e "${YELLOW}Returning to Services Menu...${WHITE}"
               ;;
            "Start a Service")
	    systemctl list-units --type=service | awk 'NR > 1 {print $1}' | head -n -7
            read -p "Enter service name to start: " service
            sudo systemctl start $service
            echo -e "${GREEN}$service started.${WHITE}"
	    echo -e "${YELLOW}Returning to Services Menu...${WHITE}"
               ;;
            "Stop a Service")
	    systemctl list-units --type=service | awk 'NR > 1 {print $1}' | head -n -7
            read -p "Enter service name to stop: " service
            sudo systemctl stop $service
            echo -e "${ORANGE}$service stopped.${WHITE}"
	    echo -e "${YELLOW}Returning to Services Menu...${WHITE}"
               ;;
            "Back to Main Menu") 
	       main_menu
               ;;
            *) echo -e "${RED}Invalid option! Please select a number from the list.${WHITE}" 
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
		if id "$username" &>/dev/null; then
		    echo -e "${RED}The username $username already exists${WHITE}"
		else
		    echo "Adding the new user $username..."
		    sudo useradd -m $username
		    echo "Creating the password for $username..."
		    sudo passwd $username
		    echo -e "${LMAGENTA}User $username has been successfully added! ${WHITE}"
		fi
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
		;;
	    "Give Root Permission to User")
     		awk -F: ‘{ print $1 }’ /etc/passwd
		read -p "Enter the username to give permission to: " username
		if id "$username" &>/dev/null; then
		    sudo usermod -a -G root $username
		    echo -e "${LMAGENTA}User $username has been given root permissions${WHITE}"
		else
		    echo -e "${RED}User $username does not exist ${WHITE}"
		fi
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
		;;
            "Delete User")
	    	awk -F: ‘{ print $1 }’ /etc/passwd
                read -p "Enter username to delete: " username
                if id "$username" &>/dev/null; then
                    sudo userdel -r $username 2>/dev/null
		    echo -e "${LMAGENTA}User $username has been successfully deleted! ${WHITE}"
                else
                    echo -e "${RED}User $username does not exist ${WHITE}"
                fi
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
                ;;
            "Show Connected Users")
		echo -e "${LMAGENTA}Showing connected users${WHITE}"
		who | awk '{print $1}'
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
                ;;
            "Show User Groups")
	    	awk -F: ‘{ print $1 }’ /etc/passwd
                read -p "Enter username to list groups: " username
                if id "$username" &>/dev/null; then
                    echo -e "${LMAGENTA}Showing groups of $username... ${WHITE}"
		    groups $username
                else
                    echo -e "${RED}User $username does not exist.${WHITE}"
                fi
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
                ;;
            "Disconnect Remote User")
		read -p "Enter username to disconnect: " username
		if who | grep -q "$username"; then
		    terminal=$(who | awk -v user="$username" '$1 == user { print $2 }')
		    sudo pkill -t "$terminal"
		    echo -e "${LMAGENTA} The remote user ${CYAN}$username ${LMAGENTA}has been disconnected ${WHITE}"
		else
		    echo -e "${RED}The remote user $username is not currently connected ${WHITE}"
		fi
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
                ;;
            "Change User Group")
	    	awk -F: ‘{ print $1 }’ /etc/passwd
		read -p "Enter the username to have group changed: " username
		if id "$username" &>/dev/null; then
		    read -p "Enter the group name to change to: " groupname
			if id "$groupname" &>/dev/null; then
			    sudo usermod -g $groupname $username
			    echo -e "${LMAGENTA}User $username has been added to $groupname ${WHITE}"
			else
			    echo -e "${RED}Group $groupname does not exist ${WHITE}"
			fi
		else
		    echo -e "${RED}User $username does not exist${WHITE}"
		fi
		echo -e "${LMAGENTA}Returning to User Management... ${WHITE}"
                ;;
            "Back to Main Menu")
	    	main_menu
                ;;
            *) echo -e "${RED}Invalid option! Please select a number from the list. ${WHITE}"
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
		if pushd "/home/$username" > /dev/null; then
		    read -p "Enter the name of the file: " filename
		    if [ -e "$filename" ]; then
			realpath $filename
		    else
			echo -e "${RED}File $filename does not exist. ${WHITE}"
		    fi
		    popd > /dev/null
		else
		    echo -e "${RED}User $username does not exist. ${WHITE}"
		fi
		echo -e "${ORANGE}Returning to File Management... ${WHITE}"
                ;;
            "Show 10 Largest Files")
		echo -e "${ORANGE}Displaying your 10 largest files... ${WHITE}"
		ls -lS | head
		echo -e "${ORANGE}Returning to File Management... ${WHITE}"
                ;;
            "Show 10 Oldest Files")
		echo -e "${ORANGE}Dislaying your 10 oldest files... ${WHITE}"
		ls -lt | tail
		echo -e "${ORANGE}Returning to File Management... ${WHITE}"
                ;;
            "Send File via Email")
		read -p "Enter file to be sent by email: " filename
		if [ -e "$filename" ]; then
		    read -p "Enter the email of the recipient: " email
		    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
			read -p "Are you sure you want to send $filename to $email? [y/n]: " answer
			if [[ "$answer" == [yY] ]]; then
			    ATTACHMENT=$(realpath "$filename")
			    echo "Email sent from Bash." | mailx -s "$filename Attached" -A "$ATTACHMENT" "$email"
			    if [ $? -eq 0 ]; then
				echo -e "${ORANGE}Email sent successfully ${WHITE}"
			    else
				echo -e "${RED}Email failed to send ${WHITE}"
			    fi
			else
			    echo -e "${RED}Email will not be sent ${WHITE}"
			fi
		    else
			echo -e "${RED}The email $email is not a valid email ${WHITE}"
		    fi
		else
		    echo -e "${RED}The file $filename does not exist in the directory $(pwd) ${WHITE}"
      		fi
		echo -e "${ORANGE}Returning to File Management... ${WHITE}"
                ;;
            "Back to Main Menu") 
	    	main_menu 
                ;;
            *) echo -e "${RED}Invalid option! Please select a number from the list.${WHITE}" 
                ;;
        esac
    done
}

main_menu 
