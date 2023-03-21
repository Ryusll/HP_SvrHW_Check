#!/bin/bash
###########################################################################################
######## require locfg.pl, Get_EmHealth.xml            				###########
######## locfg.pl and Get_EmHealth.xml same path and in home_dir 		###########
######## perl locfg.pl -s [iLO IP] -f [Use config file] -u [User] -p [Password] ###########
###########################################################################################

date=`date +%Y%d%m%H`
#need home_dir path changing 
home_dir=/root/ez_tool/health_check
work_dir=/root/ez_tool/health_check/$date

mkdir -p $work_dir


hp_ilo_user="hpadmin"
hp_ilo_pass="hpinvent"


date
echo "================================================================================================================"
printf "%21s | %8s | %8s | %8s | %9s | %8s | %8s \n" Server_Name FAN TEMP POWER PROCESSOR MEMORY STORAGE
echo "================================================================================================================"

for ip in `cat $home_dir/ilo_check.list`
	do
	health_check_ip=`cat $home_dir/ilo_check.list | awk -F"," '{print $1}' <<< $ip`
	server_name=`cat $home_dir/ilo_check.list | awk -F"," '{print $2}' <<< $ip`
	perl locfg.pl -s $health_check_ip -f Get_EmHealth.xml -u $hp_ilo_user -p $hp_ilo_pass >> $work_dir/ilo_check.txt
	cat $work_dir/ilo_check.txt | egrep "STORAGE STATUS|MEMORY STATUS|FANS STATUS|TEMPERATURE STATUS|PROCESSOR STATUS|POWER_SUPPLIES STATUS"| sed 's/[^a-z,A-Z,0-9,=]//g' | awk -F"=" '{print $2}' | xargs echo > $home_dir/health.txt
	FAN=`awk '{print $1}' $home_dir/health.txt`
	TEMP=`awk '{print $2}' $home_dir/health.txt`
	POWER=`awk '{print $3}' $home_dir/health.txt`
	PROCESSOR=`awk '{print $4}' $home_dir/health.txt`
	MEMORY=`awk '{print $5}' $home_dir/health.txt`
	STORAGE=`awk '{print $6}' $home_dir/health.txt`
	printf "%21s | %8s | %8s | %8s | %9s | %8s | %8s \n" $server_name $FAN $TEMP $POWER $PROCESSOR $MEMORY $STORAGE
done

echo "Typed number 1 -> Remove File, 2 -> Not Remove File"

read count
echo "[$count]"
if [[ $count == "1" ]]
then
	echo "Do you want really Remove File?"
	echo "-------------------------------"
	echo "Retyped the number"
	read count1
   if [[ $count1 == "1" ]]
   then 
	rm -rf $work_dir 
	rm -rf $home_dir/health.txt
   fi
else [[ -z $count ]] && [[ $count -gt 1 ]]
	echo "Please check your typed count"
fi



