# Kubernetes Cluster

A two instances Kubernetes cluster deployed on AWS with t3.small, the cheapest X86 option available in eu-west-1 ($0.0228 On-Demand hourly rate) with the minimal requirements (2 GB of RAM and 2 CPUs) established by [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). 

![Kubernetes Cluster Architecture](/diagrams/KubeadmClusterAWS.png)

* This diagram was draw using [app.diagrams.net](https://app.diagrams.net/), the diagram file is available on XML compressed standard deflate on [diagrams/KubeadmClusterAWS](/diagrams/KubeadmClusterAWS.png). The raw XML may be useful to see how the diagram is constructed and you can decode it folowing the steps on https://drawio-app.com/extracting-the-xml-from-mxfiles/.



## Configuring the Cluster

Currently this CDK stack creates the cluster instances and install the required packages, I want to automate cluster Bootstrap in the future but for now we need to do it manually.

1 - Connect to the Master ec2 and initialise the Kubernetes control-plane node. The --pod-network-cidr may change depending on your subnet CIDR. 

```bash
sudo su
kubeadm init --pod-network-cidr=172.31.32.0/20 --ignore-preflight-errors=NumCPUa
```

2 - The Kubernetes control-plane will be initialised and as output we get all the commands necessary to complete the cluster installation and configuration process. 

```
Your Kubernetes control-plane has been initialised successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.44.60:6443 --token 2v079w.ef14lnfbb9uac3bp \
	--discovery-token-ca-cert-hash sha256:012075442305dc4e08257cca5e048a93f5d69f5ac80e8ae2e32d447c9461f091 
```

3 - On the k8s-node1 execute the kubeadm join command above.

```bash
kubeadm join 172.31.44.60:6443 --token sxjnv5.9wm75nmdkz77098o --discovery-token-ca-cert-hash sha256:012075442305dc4e08257cca5e048a93f5d69f5ac80e8ae2e32d447c9461f091
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

4 -  On the master node, run the command to get the nodes to confirm whether the cluster is working properly.

```bash
$ kubectl get nodes
NAME                                          STATUS   ROLES           AGE   VERSION
ip-172-31-42-203.eu-west-1.compute.internal   Ready    <none>          77s   v1.24.0
ip-172-31-44-60.eu-west-1.compute.internal    Ready    control-plane   15m   v1.24.0
```


# CDK Python project!

To be able to deploy the CDK code and create the resources in AWS, you need to [install and configure the AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html).

After installing CDK, configure two environment variables below:

```bash
$export AWS_ACCESS_KEY_ID=[Your Key pair ID]
$export AWS_ACCOUNT_ID=[Your AWS account ID]
```

To manually create a virtualenv on MacOS and Linux:

```
$ python3 -m venv .venv
```

After the init process completes and the virtualenv is created, you can use the following
step to activate your virtualenv.

```
$ source .venv/bin/activate
```

If you are a Windows platform, you would activate the virtualenv like this:

```
% .venv\Scripts\activate.bat
```

Once the virtualenv is activated, you can install the required dependencies.

```
$ pip install -r requirements.txt
```

At this point you can now synthesize the CloudFormation template for this code.

```
$ cdk synth
```

Deploy the CDK stack on AWS

```
$ cdk deploy
```

To add additional dependencies, for example other CDK libraries, just add
them to your `setup.py` file and rerun the `pip install -r requirements.txt`
command.

## Useful commands

 * `cdk ls`          list all stacks in the app
 * `cdk synth`       emits the synthesized CloudFormation template
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `cdk diff`        compare deployed stack with current state
 * `cdk docs`        open CDK documentation

Enjoy!
