#!/bin/sh
# Configuring kubernetes repository
sudo su
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

#Configuring SElinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#Configuring container runtime
yum update -y
amazon-linux-extras enable docker
yum install -y containerd iproute-tc
systemctl enable --now containerd

#Installing kubelet and kubeadm
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
yum remove -y go
systemctl enable --now kubelet

#Configuring kernel parameters
echo br_netfilter > /etc/modules-load.d/br_netfilter.conf
systemctl restart systemd-modules-load.service
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.ipv4.ip_forward=1

#Installing go18
wget https://storage.googleapis.com/golang/getgo/installer_linux
chmod +x ./installer_linux
./installer_linux 
source ~/.bash_profile

#Configure kube-bench report
mkdir -p /opt/cisreport
cat <<EOF > /opt/cisreport
/tmp/kubebenchreport
kube-bench | grep "\[FAIL\] 1." 
EOF
