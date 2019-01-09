#!/bin/bash
#关闭防火墙及关闭selinux
systemctl disable firewalld
systemctl stop firewalld
setenforce 0
 
#配置阿里源
cat >> /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF
 
#安装kubernetes
yum install -y docker kubelet-1.11.0-0 kubeadm-1.11.0-0 kubectl-1.11.0-0  kubernetes-cni
 
#开启服务
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
 
#docker加速
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://43jugwwr.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
 
#下载镜像
images=(kube-proxy-amd64:v1.11.0 kube-scheduler-amd64:v1.11.0 kube-controller-manager-amd64:v1.11.0 kube-apiserver-amd64:v1.11.0
etcd-amd64:3.2.18 pause-amd64:3.1 kubernetes-dashboard-amd64:v1.8.3 k8s-dns-sidecar-amd64:1.14.8 k8s-dns-kube-dns-amd64:1.14.8
k8s-dns-dnsmasq-nanny-amd64:1.14.8 coredns:1.1.3)
for imageName in ${images[@]} ; do
  docker pull keveon/$imageName
  docker tag keveon/$imageName k8s.gcr.io/$imageName
  docker rmi keveon/$imageName
done
docker tag  k8s.gcr.io/pause-amd64:3.1 k8s.gcr.io/pause:3.1
 
 
#设置内核参数
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1
 
#禁用swap（虚拟内存）和移除etcd
sudo swapoff -a
yum remove -y etcd
rm -rf /var/lib/etcd/
 
#加入集群
 kubeadm join 192.168.51.213:6443 --token 0wexnp.k9cne3pudbryptpg --discovery-token-ca-cert-hash sha256:9381842503861a79babfb8d4790e5f1a7eebaf8e7a0ed4237fd5c781d4d664d0 
 
 
 


