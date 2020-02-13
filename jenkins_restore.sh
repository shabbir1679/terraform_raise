#!/bin/bash 

if [ ! -f /var/jenkins_home/initialjenkins.tar ]; then
	    echo "initialjenkins.tar File not found!"
	    /usr/bin/aws s3 cp s3://developer-data-toolstsyspropenterprise-us-east-1-tsys/backups/jenkins/initialjenkins.tar /var/jenkins_home/
	    tar -zxvf /var/jenkins_home/initialjenkins.tar -C /var/ 
	    chmod -R 777 /var/jenkins_home 
	    chown -R 1000:1000 /var/jenkins_home
    else
    echo "initialjenkins.tar File found!"
    
    	if [ ! -f /var/jenkins_home/backups/latest.tar ]; then
    	   echo "latest.tar Not File found"
       /usr/bin/aws s3 cp s3://developer-data-toolstsyspropenterprise-us-east-1-tsys/backups/jenkins/$APP_NAME/backups/latest.tar /var/jenkins_home/
       tar -zxvf /var/jenkins_home/latest.tar -C /var/ 
       chmod -R 777 /var/jenkins_home 
       chown -R 1000:1000 /var/jenkins_home
    else
       echo "latest.tar File found"
    fi 
fi

cd /var/jenkins_home 
export small=`echo $APP_NAME`-small
export medium=`echo $APP_NAME`-medium
export large=`echo $APP_NAME`-large
export xlarge=`echo $APP_NAME`-xlarge

/bin/sed -i "s/di-small/$small/g" config.xml
/bin/sed -i "s/di-medium/$medium/g" config.xml
/bin/sed -i "s/di-large/$large/g" config.xml
/bin/sed -i "s/di-xlarge/$xlarge/g" config.xml
/bin/sed -i "s%app: di%app: $APP_NAME%g" config.xml
/bin/sed -i "s%https://jenkins-cloud.tpp.tsysecom.com/di/%https://jenkins-cloud.tpp.tsysecom.com/$APP_NAME/%g" config.xml
/bin/sed -i "s%https://jenkins-cloud.tpp.tsysecom.com/di/%https://jenkins-cloud.tpp.tsysecom.com/$APP_NAME/%g" jenkins.model.JenkinsLocationConfiguration.xml
