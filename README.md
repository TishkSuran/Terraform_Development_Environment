# Terraform_Development_Environment

## Overview
This Terraform configuration sets up a comprehensive development environment on AWS. It includes infrastructure components such as a Virtual Private Cloud, internet gateway, route tables, security groups, and an EC2 instance.
<br>


### Key Components
<ul>
    <li><strong>Providers Block:</strong> Establishes AWS as the provider with version constraints.</li>
    <li><strong>Local Variables Block:</strong> Defines local variables for modularity and reusability.</li>
    <li><strong>VPC Resource Block:</strong> Creates a VPC with DNS support and hostnames enabled.</li>
    <li><strong>Availability Zones Data Block:</strong> Retrieves information about AWS availability zones.</li>
    <li><strong>Internet Gateway Resource Block:</strong> Establishes an internet gateway for internet connectivity.</li>
    <li><strong>Route Table Resource Block:</strong> Defines a route table for routing traffic within the VPC.</li>
    <li><strong>Route Resource Block:</strong> Creates a route for outbound internet traffic.</li>
    <li><strong>Route Table Association Resource Block:</strong> Associates a subnet with a route table.</li>
    <li><strong>Security Group Resource Block:</strong> Configures a security group with specific inbound and outbound rules.</li>
    <li><strong>Key Pair Resource Block:</strong> Creates an AWS key pair for SSH authentication.</li>
    <li><strong>Docker Installation Bash Script:</strong> A Bash script for installing Docker on an Ubuntu server.</li>
    <li><strong>EC2 Instance Resource Block:</strong> Provisions an EC2 instance with specified configurations and user data.</li>
    <li><strong>SSH Configuration Bash Script:</strong> Appends SSH configuration settings after EC2 instance creation.</li>
</ul>

<br>

### Usage
<ol>
  <li>Configure your AWS credentials.</li>
  <li>Replace all instances of local files and provide your own local path.</li>
  <li>Modify variables in the Terraform files as needed.</li>
  <li>Run 'terraform init' and 'terraform apply' to create the infrastructure.</li>
</ol>

<br>

### Terraform Providers Block
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}
```
In the provided Terraform configuration, we establish the groundwork for managing infrastructure on AWS. The <strong>'terraform'</strong> block sets the stage, indicating our dependency on the AWS provider and specifying version constraints to ensure compataibility. The <strong>'required_providers'</strong> section precisely identifies the source as "hashicorp/aws" and sets a version constraint of "~> 5.0" (a pessimistic version constraint, meaning Terraform can only use AWS providers within the 5.x series, including bug fixes and minor updates but excluding major version changes). Following this, the <strong>'provider "aws"' block </strong> configures the AWS provider with the information needed to connect, such as the desired AWS region, set here to "eu-west-2" (London) but should be configured to your nearest AWS region. This structured approach ensures version control as well and maintainability and consistency. 

<br>

### Local Variables Block
```hcl
locals {
  cidr     = "10.123.0.0/16"
  az       = "eu-west-2a"
  instance = "t2.micro"
}
```
Here we define three local variables to be used later in the Terraform configuration to make it more modular, reusable and easier to maintain. These values are local to the configuration and are not exposed to the Terraform state or external systems. 

<br>

### Resource Block for AWS Virtual Private Cloud
```hcl
resource "aws_vpc" "main_vpc" {
  cidr_block           = local.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev"
  }
}
```
This resource block creates an AWS VPC with a specific CIDR block, enables DNS hostanames and support, and assigns a tag with the name "Dev" for identification. Resource blocks in Terraform define the infrastructure components you want to provision, and each resource has specific configuration options depending on the type of resource being created. 

For those of you not familiar with networking or AWS, here is a brief explanation of the components used within this resource block:
<ol>
  <li><strong>CIDR Block:</strong></li> CIDR stands for Classless Inter Domain Routing. A CIDR block is a notation that represents a range of IP addresses. It consists of an IP address and a prefix length, separated by a slash. It works as follows, say we have a CIDR notation of "10.0.0.0/16", the "10.0.0.0" is the base IP address and the "/16" indicates the prefix length. In this case, it means that the first 16 bits of the IP address are fixed, and the remaining 16 bits are variable.</li>
  <li><strong>VPC (Virtual Private Cloud):</strong></li> VPC stands for virtual private cloud and is a virtual network, dedicated to your AWS account. It provides a logically isolated section of the AWS cloud where you can launch AWS resources.
  <li><strong>DNS (Domain Name System): </strong></li>DNS is a system that translates human readable domain names into IP addresses that computers use to identify each other on a network. It acts as a directory for the internet, allowing users to access websites in easy to remember domain names instead of numerical IP addresses. In the context of AWS, enabling DNS in a VPC allows instances within the VPC to have automatically assigned DNS hostnames.
</ol>

<br>

### AWS Availability Zones Data Block

```hcl
data "aws_availability_zones" "available" {}

data "aws_availability_zones" "good_zones" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
```

In Terraform, the <strong>'data'</strong> block is used to retrieve information without creating resources. The script above employs the <strong>'aws_avilability_zone'</strong> data source to gather details about AWS availability zones. The first instance, aliased as "available", queries all availabillity zones without specific filters. The second instance, aliased as "good_zones", applies filters to narrow down the results, targeting availability zones with the state "available" and opt in status of "opt-in-not-required". Data blocks, read only in nature, play a crucial role in dynamically fetching information for use in other parts of the Terraform configuration as you will see.

<br>

### AWS Internet Gateway Resource Block

```hcl
resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Dev IGW"
  }
}
```

In this resource block, we create an AWS internet gateway named "main_internet_gateway". This internet gateway is associated with the virtual private cloud we previously created, we link them using an attribute reference within the Terraform block <strong>vpc_id = aws_vpc.main_vpc.id</strong>. This internet gateway is what provides a path for network traffic to travel between our VPC and the public internet. It acts as a bridge between the two networks, enabling inbound and outbound connections from resources within the VPC. 

<br>

### AWS Route Table Resource Block

```hcl
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}
```

A route table contains a set of rules, called routes, that determine where network traffic from our gateway is directed. This configuration establishes a route table within the VPC and assigns the given tags for identification. 

<br>

### AWS Route Resource Block

```hcl
resource "aws_route" "main_route" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_internet_gateway.id
}
```

In this resource block, we create an AWS route named 'main_route'. This route is associated with both the route table as well as the internet gateway through the use of attribute references. The fact that the destination cidr block is set to "0.0.0.0/0" (a wild card that represents all possible IP addresses), it means that this route will be used for all outbound traffic.

<br>

### AWS Route Table Association 

```hcl
resource "aws_route_table_association" "main_rta" {
  route_table_id = aws_route_table.main_route_table.id
  subnet_id      = aws_subnet.main_subnet.id
}
```

This resource block is associating the previously created subnet with the previously created route table. This association will determine which route table will be used for routing traffic for resources within that specific subnet. 

<br>

### AWS Security Group Resource 

```hcl
resource "aws_security_group" "main_security_group" {
  name        = "main_security_group"
  description = "Main Security Group"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip_address}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
In AWS, a Security Group serves as a virtual firewall for instances, controlling both inbound and outbound traffic. It is associated with instances, specifying rules to allow or deny traffic based on protocols, ports and IP addresses. Security Groups are stateful, automatically allowing response traffic, and operate on a default deny principle, requiring explicit rule definitions. They offer granular control over network access to instances and provide a crucial layer of securitiy for instances within the VPC. 

<br>
The <strong>'ingress'</strong> block defines inbound traffic rules for the AWS security group:
<ul>
  <li>from_port and to_port are set to 22, indicating that the rule allows incoming traffic on TCP port 22. Port 22 is commonly used for SSH (Secure Shell) access, and this rule is designed to permit SSH connections to instances associated with the Security Group.</li>
  <li><strong>'protocol'</strong> is set to "tcp", specifying the transport layer protocol for the allowed traffic, which in this case is TCP. TCP stands for transport control protocol and it handles establishing connections between two devices to pass data back and forth and detecting things like packet loss and transmission if required.</li>
</ul>
<br>
The <strong>'egress'</strong> block defines outbound traffic rules for the Security Group:
<ul>
  <li>from_port and to_port are both set to 0, indicating that no specific port range is defined for outbound traffic. This essentially allows all outbound traffic, regardless of the destination port.</li>
  <li><strong>'protocol'</strong> is set to "-1", representing all protocols. This means that the rule allows traffic of any protocol for outbound communication.</li>
  <li><strong>cird_blocks</strong> is set to [0.0.0.0/0] indicating that the rule allows outbound traffic to any destination IP address.</li>
</ul>

<br>

### AWS Key Pair Resource 

```hcl
resource "aws_key_pair" "auth" {
  key_name   = "key"
  public_key = file("/Users/Coding/.ssh/key.pub")
}
```

This block creates an AWS key pair. Key pairs are used for SSH authentication when connecting to instances. My key pair has been specified in a local file, but you will have to generate your own in order to use this script.

<br>

### The Bash Script that Installs Docker on Ubuntu Server

``` bash
#!/bin/bash

sudo apt-get update -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER

sudo systemctl start docker

sudo systemctl enable docker
```
<br>

### AWS Instance Resource 

```hcl
resource "aws_instance" "aws" {
  ami           = data.aws_ami.server_ami.id
  instance_type = local.instance

  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.main_security_group.id]
  subnet_id              = aws_subnet.main_subnet.id
  user_data              = file("userdata.tpl")

  tags = {
    Name = "Dev-Node"
  }

  root_block_device {
    volume_size = 10
  }
```

This Terraform Instance code block defines an AWS EC2 instance. It specifies the AMI using the AMI ID we obtained using the data block, sets the instance type based on the local variable we defined in the local block at the start, associates the key pair resource and subnet. It also uses the bash script attatched above which is stored in a file called "userdata.tpl" which installs docker upon launch of the instance.

<br>

### The SSH Bash Script

``` bash
cat <<EOF >> ~/.ssh/config

Host $(hostname)
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
EOF
```
<br>

### Provisoner Block

```hcl
  provisioner "local-exec" {
    command = templatefile("/Users/Coding/Desktop/Terraform_Dev_Enviroment/ssh.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "/Users/Coding/.ssh/key"
    })
    interpreter = ["bash", "-c"]
  }
```

The Terraform provisoner block allows you to define actions to be taken on local or remote resources after they are created. This Terraform provisioner block execute the Bash command attatched above to configure SSH settings, including hostanme, user and identity path after creating an AWS EC2 instance.


