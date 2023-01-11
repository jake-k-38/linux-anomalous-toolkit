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
install rkhunter to check for rootkits
validate crontab for users / root account (less /etc/crontab)
Look over any system HIDS logs
check for new users or groups ( getent group | grep "name"| sort )
check authorized_keys file for new public keys ( ~/.ssh/authorized_keys )

Find bruteforce IPs:
sudo grep "Failed password" /var/log/secure | awk '{print $11}' | uniq -c | sort -nr

Find accepted connections:
sudo grep "Accepted password" /var/log/auth.log | uniq -c | sort -nr

Find sudo commands last used:
sudo grep "sudo:" /var/log/auth.log | uniq -c | sort -nr
```
## Getting started
To run this project, Git clone it or extract, and allow executable permission. Then run it as sudo<br />
```
sudo chmod 755 anomalus.sh
```
## Usage
Simply just run the script anomalus.sh

```
sudo ./anomalus.sh
```

## Notes

https://www.activecountermeasures.com/hunting-for-persistence-in-linux-part-1-auditd-sysmon-osquery-and-webshells/
https://www.xplg.com/linux-security-investigate-suspected-break-in/
https://linuxsecurity.expert/tools/
https://medium.com/@p.matkovski/detection-of-php-web-shells-with-access-log-waf-and-audit-deamon-e798d4c95ec
