import os 

from aws_cdk import (
    Stack,
    aws_ec2 as ec2,

)

# Check if the environament variables are set
try:
    key_name=os.environ.get('AWS_ACCESS_KEY_ID')
    secret_key=os.environ.get('AWS_SECRET_ACCESS_KEY')
except (KeyError, ValueError):
    print("Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables")
    exit(1)

# Define stack properties
vpcID="vpc-98ba0ae1"
instanceType="t3.small"
instanceNames=["k8s-master", "k8s-node1"]

# Define user data
with open("./kubeadm_cluster/user_data.sh", "r") as f:
    user_data = f.read()

amzn_linux = ec2.AmazonLinuxImage(
    generation=ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
    edition=ec2.AmazonLinuxEdition.STANDARD,
    virtualization=ec2.AmazonLinuxVirt.HVM,
    storage=ec2.AmazonLinuxStorage.GENERAL_PURPOSE,
    cpu_type=ec2.AmazonLinuxCpuType.X86_64
)

from constructs import Construct

class KubeadmClusterStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = ec2.Vpc.from_lookup(self, "vpc", vpc_id=vpcID)
        sec_group = ec2.SecurityGroup(self, "k8s-sg", vpc=vpc, allow_all_outbound=True)

        # Defining ingress rules for the security group
        sec_group.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(22), "SSH from the internet.")
        sec_group.add_ingress_rule(sec_group, ec2.Port.all_tcp(), "Kubernetes API.")

        # Defining the master instance
        master_node =  ec2.Instance(
            self,
            "Master",
            instance_name="k8s-master",
            instance_type=ec2.InstanceType(instanceType),
            machine_image=amzn_linux,
            vpc=vpc,
            security_group=sec_group,
            user_data=ec2.UserData.custom(user_data), 
            key_name=os.environ.get('AWS_ACCESS_KEY_ID')
       
        )

        # Defining the node instances
        worker_node =  ec2.Instance(
            self,
            "Node1",
            instance_name="k8s-node1",
            instance_type=ec2.InstanceType(instanceType),
            machine_image=amzn_linux,
            vpc=vpc,
            security_group=sec_group,
            user_data=ec2.UserData.custom(user_data), 
            key_name=os.environ.get('AWS_ACCESS_KEY_ID'),
        )



