#!/bin/bash
date=$(date +%F)
storages=("192.168.1.228" "192.168.1.225" "127.0.0.1");
function DBBackup(){
    echo "Backuping DB...";
    pg_dump -U roman howto_wiki > /root/backup_scripts/$1"_howto_wiki.sql"
    openssl enc -aes-256-ctr -in /root/backup_scripts/$1"_howto_wiki.sql" -out $date"_howto_wiki.enc" -k /data/galatea.png
    size=$(wc -c <$1"_howto_wiki.enc")
    if [ $size -ge 1000 ]; then
    	echo -e "Database backup...[\x1B[32mOK\e[0m]"
    else
	echo -e "Database backup...[\x1B[31mFailed\e[0m]"
    fi
}
function RemStorageAvailability(){
    ip_ping=$(ping -c 1 $1 1> /dev/null && echo '1' || echo '0')
    echo -n "Accessing $1 ICMP...";
    if [ $ip_ping -eq '1' ]; then
	echo -e "[\x1B[32mOK\e[0m]"
	#smbclient -E -U roman //127.0.0.1/datashare nemesis -c 'get \\sysbcp.conf /dev/fd/1' 2>/dev/null | cat
	IFS=$'\r\n' GLOBIGNORE='*' command eval  "XYZ=($(smbclient -E -U SysBackup //$1/SysBackup backup00system -c 'get \\GalateaBackup\\sysbcp.conf /dev/fd/1' 2>/dev/null | cat
	))"
	echo -n "Accessing $1 SMB..."
	IFS=. read -a o <<< $1  #adresa poslední octet
	if [ ${XYZ[2]} -eq ${o[3]} ]; then
	    echo -e "[\x1B[32mOK\e[0m]";
	else
	    echo -e "[\x1B[31mFailed\e[0m]";
	fi
	#mapfile -t lines < <(smbclient -E -U SysBackup //192.168.1.228/GalateaBackup backup00system -c 'get \\sysbcp.conf /dev/fd/1' 2>/dev/null | cat)
	#echo ${lines[0]}
	#mapfile -t lines < <(echo 1)
	#printf '%s\n' "${lines[@]}"
    else
        echo -e "[\x1B[31mFailed\e[0m]"
    fi
}
function GetConfigFiles(){
    StorageAvailability ${storages[0]}
    
}
function UploadBackups(){
    echo "upload";
}
#DBBackup $date
RemStorageAvailability ${storages[0]}
RemStorageAvailability ${storages[1]}
RemStorageAvailability ${storages[2]}
#echo "Checking remote storage availability..."
#md5=($(md5sum galatea_wiki.pgbck))
#IFS=$'\r\n' GLOBIGNORE='*' command eval  'XYZ=($(cat /root/backup_scripts/sysbcp.conf))'
#echo "${XYZ[2]}"
#openssl enc -aes-256-ctr -in /data/galatea_wiki.pgbck -out sysbcp.enc -k /data/galatea.png
#decrypt openssl enc -aes-256-cbc -d -in file.txt.enc -out file.txt -k PASS
#smbget -R smb://roman:nemesis@127.0.0.1/datashare/sysbcp.conf
#$sudo -u roman pg_dump howto_wiki > /data/galatea_wiki_$date.pgbck
#echo galatea_$date.jpg
#echo -e "Database backup...[\x1B[32mOK\e[0m]"
#echo -e "Database backup...[\x1B[31mFailed\e[0m]"
#echo -e "Database backup...[\x1B[33mUnavailable\e[0m]"
