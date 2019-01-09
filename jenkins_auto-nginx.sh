#!/bin/bash
DATE=`date +%m%d%H%M`
DIR="/root/.jenkins/workspace/nginx/"
ip='master:5000'
sudo /bin/docker build -t $ip\/nginx_$DATE $DIR | tee $DIR/Docker_build_result.log
docker push $ip\/nginx_$DATE
ssh root@node1 "docker pull $ip\/nginx_$DATE"
ssh root@node1 "docker pull $ip\/nginx_$DATE"
/usr/bin/kubectl delete -f /k8s/nginx-rc.yaml
sed -i "16s/.*/          image: master:5000\/nginx_$DATE/g" /k8s/nginx-rc.yaml
/usr/bin/kubectl create -f /k8s/nginx-rc.yaml
/usr/bin/kubectl apply -f /k8s/nginx-svc.yaml
