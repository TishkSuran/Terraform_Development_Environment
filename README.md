# Terraform_Development_Environment

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
<br>
<br>

```hcl
locals {
  cidr     = "10.123.0.0/16"
  az       = "eu-west-2a"
  instance = "t2.micro"
}
```
Here we define three local variables to be used later in the Terraform configuration to make it more modular, reusable and easier to maintain. These values are local to the configuration and are not exposed to the Terraform state or external systems. 


<br>
<br>
<br>

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
  <li><strong>CIDR Block:</strong> CIDR stands for Classless Inter Domain Routing. A CIDR block is a notation that represents a range of IP addresses. It consists of an IP address and a prefix length, separated by a slash. It works as follows, say we have a CIDR notation of "10.0.0.0/16", the "10.0.0.0" is the base IP address and the "/16" indicates the prefix length. In this case, it means that the first 16 bits of the IP address are fixed, and the remaining 16 bits are variable.</li>
</ol>



