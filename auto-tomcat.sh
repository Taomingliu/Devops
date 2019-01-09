#!/bin/bash
DATE=`date +%m%d%H%M`
DIR="/root/.jenkins/workspace/tomcat/"
ip='master:5000'
sudo /bin/docker build -t $ip\/tomcat_$DATE $DIR | tee $DIR/Docker_build_result.log
docker push $ip\/tomcat_$DATE
#ssh root@node1 "docker pull $ip\/tomcat_$DATE"
#ssh root@node2 "docker pull $ip\/tomcat_$DATE"
#ssh root@node3 "docker pull $ip\/tomcat_$DATE"
sed -i "16s/.*/          image: master:5000\/tomcat_$DATE/g" /k8s/tomcat-rc.yaml
/usr/bin/kubectl apply -f /k8s/tomcat-rc.yaml
/usr/bin/kubectl apply -f /k8s/tomcat-svc.yaml
