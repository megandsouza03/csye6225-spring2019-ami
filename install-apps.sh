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
wget http://archive.apache.org/dist/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz

# install tomcat to the /opt/tomcat directory
sudo mkdir /opt/tomcat 
sudo tar xvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
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

#Creating cloudwatch-config.json file
cd ~
touch cloudwatch-config.json

cat > cloudwatch-config.json << EOF
{
    "agent": {
        "metrics_collection_interval": 10,
        "logfile": "/var/logs/amazon-cloudwatch-agent.log"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/opt/tomcat/logs/csye6225.log",
                        "log_group_name": "csye6225_spring2019",
                        "log_stream_name": "webapp"
                    }
                ]
            }
        },
        "log_stream_name": "cloudwatch_log_stream"
    },
    "metrics": {
    	"metrics_collected": {
    		"statsd":{
    			"service_address": ":8125",
    			"metrics_collection_interval":10,
    			"metrics_aggregation_interval":0
    		}
    	}
    }
}
EOF

touch csye6225.log
sudo chgrp -R tomcat csye6225.log
sudo chmod -R g+r csye6225.log
sudo chmod g+x csye6225.log
sudo mv csye6225.log /opt/tomcat/logs/csye6225.log

#Installing cloud-watch config agent
cat cloudwatch-config.json
sudo mv cloudwatch-config.json /opt/cloudwatch-config.json

cd ~

sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch-config.json -s


cd ~

sudo wget https://s3.amazonaws.com/configfileforcloudwatch/amazon-cloudwatch-agent.service
sudo cp amazon-cloudwatch-agent.service /usr/lib/systemd/system/
sudo systemctl enable amazon-cloudwatch-agent.service
sudo systemctl start amazon-cloudwatch-agent.service
sudo systemctl status amazon-cloudwatch-agent.service
sudo echo 'SUCCESS!!!!!!!'

exit 0
