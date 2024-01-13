# Terraform_Development_Environment

Here we define three local variables to be used later in the Terraform configuration to make it more modular, reusable and easier to maintain. These values are local to the configuration and are not exposed to the Terraform state or external systems. 

```hcl
locals {
  cidr     = "10.123.0.0/16"
  az       = "eu-west-2a"
  instance = "t2.micro"
}
```

Here we define three local variables to be used later in the Terraform configuration to make it more modular, reusable and easier to maintain. These values are local to the configuration and are not exposed to the Terraform state or external systems.
