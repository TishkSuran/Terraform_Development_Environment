# Terraform_Development_Environment

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
In the provided Terraform configuration, we establish the groundwork for managing infrastructure on AWS. The <strong>'terraform'</strong> block sets the stage, indicating our dependency on the AWS provider and specifying version constraints to ensure compataibility. The <strong>'required_providers'</strong> section precisely identifies the source as "hashicorp/aws" and sets a version constraint of "~> 5.0" (a pessimistic version constraint, meaning Terraform can only use AWS providers within the 5.x series, including bug fixes and minor updates but excluding major version changes). Following this, the <strong>'provider "aws"' block </strong> configures the AWS provider with the information needed to connect, such as the desired AWS region, set here to "eu-west-2" (London) but should be configured to your nearest AWS region. This structured appraoch ensures version control as well and maintainability and consistency. 

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

### AWS Route Table

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

### AWS Route 

```hcl
resource "aws_route" "main_route" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_internet_gateway.id
}
```

In this resource block, we create an AWS route named 'main_route'. This route is associated with both the route table as well as the internet gateway through the use of attribute references. The fact that the destination cidr block is set to "0.0.0.0/0" (a wild card that represents all possible IP addresses), it means that this route will be used for all outbound traffic.
