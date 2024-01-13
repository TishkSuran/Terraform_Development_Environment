# Terraform_Development_Environment

In the provided Terraform configuration, we establish the groundwork for managing infrastructure on AWS. The <strong>'terraform'</strong> block sets the stage, indicating our dependency on the AWS provider and specifying version constraints to ensure compataibility.

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

Here we define three local variables to be used later in the Terraform configuration to make it more modular, reusable and easier to maintain. These values are local to the configuration and are not exposed to the Terraform state or external systems. 

```hcl
locals {
  cidr     = "10.123.0.0/16"
  az       = "eu-west-2a"
  instance = "t2.micro"
}
```


