#!/bin/sh

sudo su

sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1/net.ipv4.ip_forward= 1
EOF

sysctl -p /etc/sysctl.conf

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


yum update -y
amazon-linux-extras enable docker
yum install -y containerd iproute-tc
systemctl enable --now containerd


yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet


# Master node setup
# kubeadm init --pod-network-cidr=172.31.32.0/20 --ignore-preflight-errors=NumCPUa
# systemctl enable kubelet && systemctl start kubelet



