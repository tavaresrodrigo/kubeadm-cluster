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

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


yum update -y
amazon-linux-extras enable docker
yum install -y containerd iproute-tc
systemctl enable --now containerd
sysctl --system


yum install -y kubelet kubeadm kubectl go --disableexcludes=kubernetes
systemctl enable --now kubelet

echo br_netfilter > /etc/modules-load.d/br_netfilter.conf
systemctl restart systemd-modules-load.service
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.ipv4.ip_forward=1
sysctl -a
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl --system
sysctl -a
sysctl -w net.bridge.bridge-nf-call-iptables=1


# Master node setup
# kubeadm init --pod-network-cidr=172.31.32.0/20 --ignore-preflight-errors=NumCPUa
# systemctl enable kubelet && systemctl start kubelet
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"


