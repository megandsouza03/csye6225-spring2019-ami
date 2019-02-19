#!/bin/bash -xe

sudo yum install ruby ntp wget java-1.8.0-openjdk-devel -y
# 2. create a tomcat user :: 
# member of the tomcat group, home directory of /opt/tomcat (install), shell of /bin/false (nobody login)
sudo groupadd tomcat
sudo useradd -M -s /sbin/nologin -g tomcat -d /opt/tomcat tomcat

# B | installation 
cd ~
mkdir development
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
# paste the content of tomcat.service [https://gist.github.com/ryanpadilha/a7cb7a31bdbea05fdef3ab3716ca0c9c]
sudo mv tomcat.service /usr/lib/systemd/system/tomcat.service
# reload Systemd to load the tomcat unit file
sudo systemctl daemon-reload

# start tomcat service
sudo systemctl enable tomcat.service
sudo systemctl start tomcat.service
sudo systemctl status tomcat

# enable the tomcat service start on server boot (optional)

# Created symlink from /etc/systemd/system/multi-user.target.wants/tomcat.service to /etc/systemd/system/tomcat.service.

# change de port of tomcat webserver in conflicts
# search for <Connector port="8080" ...
#sudo vim /opt/tomcat/conf/server.xml

# E | tomcat web management interface
# edit tomcat-users.xml file
#sudo vim /opt/tomcat/conf/tomcat-users.xml

# add line <user username="admin" password="password" roles="manager-gui,admin-gui"/>
# remove restrict access to the tomcat manager :: comment ip address (loopback)
# 1. manager app
#sudo vim /opt/tomcat/webapps/manager/META-INF/context.xml

# 2. host-manager app
#sudo vi /opt/tomcat/webapps/host-manager/META-INF/context.xml

# restart the service!
sudo echo 'SUCCESS!!!!!!!'
sudo find / -name "tomcat8"
exit 0