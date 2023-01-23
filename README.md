# linux-anomalus-toolkit
Anomalus is a Bash-based Linux incident response toolkit.
## Table of contents
* [General info](#general-info)
* [Getting started](#getting-started)
* [Usage](#usage)

## General info
The toolkit is intended to aid in the automated identification of potential IOCs and abnormalities in order to determine the machine's health.

The following are some useful one-liner snippets and generic commands to run while searching for suspicious behavior on a Linux system. 
```
run <w> to see if anybody is still logged in
run <last> to see log in history
run <history> to see command history in user terminal (before reboot recover) history | cut -c 8- > histback_user1.txt
run <lastcomm name>, <sa -u name> Use psacct or acct to view process activites of each user
run aureport (tool comes with auditd)
review the auth/ssh log and look for any accepted sessions/bruteforce
review apache/nginx access logs - https://github.com/nanopony/apache-scalp
install rkhunter to check for rootkits
validate crontab for users / root account (less /etc/crontab)
Look over any system HIDS logs
check for new users or groups ( getent group | grep "name"| sort )
check authorized_keys file for new public keys ( ~/.ssh/authorized_keys )

Find bruteforce IPs:
sudo grep "Failed password" /var/log/secure | awk '{print $11}' | uniq -c | sort -nr

Find accepted connections:
sudo grep "Accepted password" /var/log/auth.log | uniq -c | sort -nr

Display and sort number of connections per IP and port:
netstat -ntu | awk '{ sub(/(.*):/,"",$4); sub(/:(.*)/,"",$5); print $5,$4}' | grep ^[0-9] | sort | uniq -c | sort -nr | head -30

Find sudo commands last used:
sudo grep "sudo:" /var/log/auth.log | uniq -c | sort -nr
```
## Getting started
To run this project, Git clone it or extract, and allow executable permission. Then run it as sudo<br />
```
sudo chmod 755 anomalus.sh
```
## Usage
Simply just run the script anomalus.sh and direct output to file

```
sudo ./anomalus.sh > example.txt
```

## To-Do
Add HTML / CSV output <br />
Add more persistence checks <br />
Add file output options inside folder <br />
Add process analysis checks like "Process running from /tmp, /dev" or ""

## Notes

https://www.activecountermeasures.com/hunting-for-persistence-in-linux-part-1-auditd-sysmon-osquery-and-webshells/ <br />
https://www.xplg.com/linux-security-investigate-suspected-break-in/ <br />
https://linuxsecurity.expert/tools/ <br />
https://medium.com/@p.matkovski/detection-of-php-web-shells-with-access-log-waf-and-audit-deamon-e798d4c95ec <br />
https://sandflysecurity.com/linux-compromise-detection-command-cheatsheet.pdf <br />
