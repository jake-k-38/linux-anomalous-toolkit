#!/bin/bash

persistenceLocations=(/var/www/html/ /etc/nginx/ /etc/apache2/ /sbin /bin /usr/sbin /etc)

accessLogsLocations=(/var/log/nginix/access.log /var/log/apache/access.log)

#Could have some false positives
netFlags=(nc bash perl python php ruby java javaw)

#Apache/Nginx access log look back count for GET, POST, Top IPs (default is NEGATIVE 20)
lookBackCount=-20 #Tailor the lookback for tail / head of data

#Colorful output
#@manatwork
function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}- 
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

box_out "Started @ `date +"%m-%d-%Y %T"`"
box_out "Anomalus Response Toolkit"

#List modified ~.ssh/authorized_keys dirs for all users
echo ""
box_out "Analyzing users authorized_keys folder..."
usersDir=$(getent passwd | grep /home | cut -d: -f6)
for i in $usersDir
do
   keys=$i/.ssh/authorized_keys
   if [ -d $keys ]; then
      current_status=$(mktemp /tmp/temp-status.XXXXXX)
      find $keys -mtime -1 -type f -print > ${current_status}
      box_out "Last 24-48 hours of activity in .ssh/authorized_keys for account: $i"
      cat ${current_status}
      echo ""
      rm -f ${current_status}
   fi
done
echo ""

#List /etc/group for each user
users=$(getent passwd | grep /home | cut -d: -f1)
for i in $users
do
   echo "Group information for user: $i"
   printf "%s\n" `getent group | grep $i | sort`
done

#List crontab for each user
users=$(getent passwd | grep /home | cut -d: -f1)
for i in $users
do
   echo "Crontab jobs for user: $i"
   crontab -u $i -l
done

echo ""
box_out "Now searching for last updated files in known persistence locations..."
#Scan for most recent changes
for i in "${persistenceLocations[@]}"
do
   if [ -d $i ]; then
      current_status=$(mktemp /tmp/temp-status.XXXXXX)
      find $i -mtime -1 -type f -print > ${current_status}
      if [[ -s ${current_status} ]]; then
         box_out "Last 24-48 hours modified files for $i:"
         cat ${current_status}
         echo ""
      fi
      rm -f ${current_status}
   fi
done
box_out "If you have not made any OS updates or if you have not installed any new software like plugins and themes, please check the files!!"


echo ""
#Scan for reverse shells
current_status=$(mktemp /tmp/temp-status.XXXXXX)
lsof -Pnl +M -i4 > ${current_status}
echo ""
for flag in "${netFlags[@]}"
do
   if [ -s ${current_status} ] && cat ${current_status} 2>/dev/null | grep $flag; then
      box_out "Checking for reverse shells.."
      box_out "Suspicious connection under keyword: $flag (Expect false positives)"
      cat ${current_status} | grep $flag
      cat ${current_status} | grep $flag | awk '{print $4}'
      box_out "If you do not recognize these actives connections, investigate!!
      (The file descriptors 0, 1 and 2 stand for STDIN, STDOUT and STDERR *could include 3u, 4u)"
      echo ""
   fi
   rm -f ${current_status}
done

echo ""
#Check recent access logs: top requests/most recent for GET, POST 
#Top 20 IPs, and most recent IPs
#Credit goes to "Spike" script was made by Bobby I. <bobby@bobbyiliev.com>
#https://github.com/bobbyiliev/quick_access_logs_summary

for log in "${accessLogsLocations[@]}"
do
   if [ -f $log ] && [ -s $log ]; then
      box_out "Scanning the following access log: $log
      # - POST requests
      # - GET requests
      # - IP logs"
      echo ""
      box_out "Top 20 GET"
      cat $log 2>/dev/null | grep -v 'ftp.' | grep GET | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail $lookBackCount |  sed  's/^ *//g' | column -s '' -s ' ' -t
      
      box_out "Most recent GET"
      cat $log 2>/dev/null | grep -v 'ftp.' | grep GET | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail $lookBackCount  | sed  's/^ *//g' | column -s '' -s ' ' -t
      
      box_out "Top 20 POST"
      cat $log 2>/dev/null | grep -v 'ftp.' | grep POST | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail $lookBackCount  | sed  's/^ *//g' | column -s '' -s ' ' -t
      
      box_out "Most recent POST"
      cat $log 2>/dev/null | grep -v 'ftp.' | grep POST | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail $lookBackCount  | sed  's/^ *//g' | column -s '' -s ' ' -t
      
      box_out "Top 20 IP REQUESTS"
      cat $log 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head $lookBackCount | sed  's/^ *//g' | column -s ' ' -s ' ' -t
      
      box_out "Most recent IP REQUESTS"
      tail -n 1000 $log 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head $lookBackCount | sed  's/^ *//g' | column -s '' -s ' ' -t
      
   fi
done

box_out 'Finished @', `date +"%m-%d-%Y %T"`
