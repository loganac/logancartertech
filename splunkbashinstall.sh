#!/bin/bash
 echo
 echo '##################################################'
 echo '#                                                #'
 echo '# Welcome to the Splunk 9.0.1 auto-installer     #'
 echo '# for CentOS 7 x64.                              #'
 echo '# Last updated 07/28/2022.                       #'
 echo '# This script is for very basic Splunk install   #'
 echo '# This sets up Splunk with best practice Ulimits #'
 echo '# and THP disabled                               #'
 echo '##################################################'
 echo
 echo
 echo "Switch to root user to configure Linux for Splunk and Splunk Install"
 echo
 #
 ##
 echo
 echo "Setting Ulimts and Disabling Transparent Huge Pages"
 echo
 ##
 #
 echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
 echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
 echo "[Unit]" > /etc/systemd/system/disable-thp.service
 echo "Description=Disable Transparent Huge Pages" >> /etc/systemd/system/disable-thp.service
 echo "" >> /etc/systemd/system/disable-thp.service
 echo "[Service]" >> /etc/systemd/system/disable-thp.service
 echo "Type=simple" >> /etc/systemd/system/disable-thp.service
 echo 'ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled && echo never > /sys/kernel/mm/transparent_hugepage/defrag"' >> /etc/systemd/system/disable-thp.service
 echo "Type=simple" >> /etc/systemd/system/disable-thp.service
 echo "" >> /etc/systemd/system/disable-thp.service
 echo "[Install]" >> /etc/systemd/system/disable-thp.service
 echo "WantedBy=multi-user.target" >> /etc/systemd/system/disable-thp.service
 systemctl daemon-reload
 systemctl start disable-thp
 systemctl enable disable-thp
 echo
 echo
 echo "Transparent Huge Pages (THP) Disabled."
 echo
 echo
 ulimit -n 64000
 ulimit -u 16000
 echo "DefaultLimitFSIZE=-1" >> /etc/systemd/system.conf
 echo "DefaultLimitNOFILE=64000" >> /etc/systemd/system.conf
 echo "DefaultLimitNPROC=16000" >> /etc/systemd/system.conf
 echo
 echo "ulimits Increased."
 echo
 echo 
 echo
 echo "Beginning Splunk Download and Install"
 echo
 echo
 yum install wget -y
 cd /tmp
wget -O splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz"
 echo
 echo
 echo "Splunk Enterprise Downloaded."
 echo
 echo
 tar -xzvf /tmp/splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz -C /opt
 rm -f /tmp/splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz
 useradd splunk
 chown -R splunk:splunk /opt/splunk
 echo
 echo
 echo "Splunk Enterpise Installed and splunk user created."
 echo
 echo
 #
 echo
 echo
 echo "Splunk booting up"
 echo
 echo
 #
 runuser -l splunk -c '/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd bitsIOpw'
 echo "Splunk admin password is password"
 echo "Stop Splunk to enable boot start"
 runuser -l splunk -c '/opt/splunk/bin/splunk stop'
 /opt/splunk/bin/splunk enable boot-start -user splunk
 echo
 echo "Splunk test start and stop complete. Enabled Splunk to start at boot. Also, adjusted splunk-launch.conf to mitigate privilege escalation attack."
 echo
 runuser -l splunk -c '/opt/splunk/bin/splunk start'
 if [[ -f /opt/splunk/bin/splunk ]]
         then
                 echo Splunk Enterprise
                 cat /opt/splunk/etc/splunk.version | head -1
                 echo "has been installed, configured, and started!"
                 echo "Visit the Splunk server using https://hostNameORip:8000 as mentioned above."
                 echo
                 echo
                 echo "                        HAPPY SPLUNKING!!!"
                 echo
                 echo
                 echo
         else
                 echo Splunk Enterprise has FAILED install!
 fi
 echo
 su - splunk
 echo
 echo "You are now the Splunk user. Be sure to perform all Splunk actions as the splunk user"
 #End of File
