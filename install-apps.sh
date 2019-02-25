#!/bin/bash -xe
sudo yum update -y
sudo yum install ruby ntp wget java-1.8.0-openjdk-devel -y
# Create a tomcat user :: 
# Member of the tomcat group, home directory of /opt/tomcat (install), shell of /bin/false (nobody login)
sudo groupadd tomcat
sudo useradd -M -s /sbin/nologin -g tomcat -d /opt/tomcat tomcat

# Moving to the user home folder
cd /home/centos

#install code-deployagent on the ec2 instance
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

#Check Service is running
sudo service codedeploy-agent status

cd ~
wget http://apache.mirrors.pair.com/tomcat/tomcat-8/v8.5.38/bin/apache-tomcat-8.5.38.tar.gz

# install tomcat to the /opt/tomcat directory
sudo mkdir /opt/tomcat 
sudo tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/
sudo cd ../../../..     
sudo cd /usr/lib/systemd/system
               
#sudo vim /etc/systemd/system/tomcat.service
cd ~
touch tomcat.service
echo '[Unit]' > tomcat.service
echo 'Description=Apache Tomcat Web Application Container' >> tomcat.service
echo 'After=syslog.target network.target' >> tomcat.service
echo '[Service]' >> tomcat.service
echo 'Type=forking' >> tomcat.service
echo 'Environment=JAVA_HOME=/usr/lib/jvm/jre' >> tomcat.service
echo 'Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid' >> tomcat.service
echo 'Environment=CATALINA_HOME=/opt/tomcat' >> tomcat.service
echo 'Environment=CATALINA_BASE=/opt/tomcat' >> tomcat.service
echo 'Environment=\"CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC\"' >> tomcat.service
echo 'Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom\"' >> tomcat.service
echo 'ExecStart=/opt/tomcat/bin/startup.sh' >> tomcat.service
echo 'ExecStop=/bin/kill -15 $MAINPID' >> tomcat.service
echo 'User=tomcat' >> tomcat.service
echo 'Group=tomcat' >> tomcat.service
echo 'UMask=0007' >> tomcat.service
echo 'RestartSec=10' >> tomcat.service
echo 'Restart=always' >> tomcat.service
echo '[Install]' >> tomcat.service
echo 'WantedBy=multi-user.target' >> tomcat.service
sudo mv tomcat.service /usr/lib/systemd/system/tomcat.service

sudo systemctl daemon-reload

# start tomcat service
sudo systemctl enable tomcat.service
sudo systemctl start tomcat.service
sudo systemctl status tomcat

sudo yum install zip unzip -y
wget https://services.gradle.org/distributions/gradle-5.0-bin.zip -P /tmp

sudo mkdir -p /opt/gradle/
sudo unzip -d /opt/gradle /tmp/gradle-5.0-bin.zip

cd ~
touch gradle.sh
echo 'export GRADLE_HOME=/opt/gradle/gradle-5.0' > gradle.sh
echo 'export PATH=${GRADLE_HOME}/bin:${PATH}' >> gradle.sh
sudo chmod +x gradle.sh
sudo mv gradle.sh /etc/profile.d/gradle.sh

source /etc/profile.d/gradle.sh
gradle -v

sudo echo 'SUCCESS!!!!!!!'

exit 0
