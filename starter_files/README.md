# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

## Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

## Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

## Instructions
### apply policy

```
script/enable_azure_policy.sh <subscription>
```

### Provision

#### Create a Packer image

1. Pre-requirement: install Packer
2. Create a resource group to hold the Packer image
```shell
az group create -n lng_udacity_packer_rg -l eastus
```
3. Create RBAC to enable Packer to authenticate to Azure using a service principal.
```shell
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"

```
- Make note of the output values (appId, client_secret, tenant_id).
4. Build the Packer image.

```shell
packer build server.json
```

#### Update varibale
1. Open file variables.tf
2. Update variable base on your environments

| variable  |  Description |  Default | Notes  |   |
|---|---|---|---|---|
| packer_resource_group_name  | Name of the resource group in which the Packer image will be created | lng_udacity_packer_rg  |   |   |
| packer_image_name  | Name of the Packer image  | lng_udacity_image_ubuntu_18.04_LTS  |   |   |
| resource_group_name  | Name of the resource group in which the resources will be created  | lng_udacity_rg  |   |   |
| location  | Location where resources will be created  | eastus  |   |   |
| tags  | Tags of AZ esources  |  source = "lng_udacity", deployby = "linhnt58"  |   |   |
| vnet_address_prefixes  | CDIR of VNET  |  ["10.0.0.0/16"] |   |   |
|  vms_min | The  number of Virtual machine   |  2 |   |   |

#### Deploy infrastructure

1. Initialize Terraform
```shell
terraform init
```
2. Create a Terraform execution plan
```shell
terraform plan -out solution.plan
```
3. Apply a Terraform execution plan
```shell
terraform apply solution.plan
```
5. Verify the results
```shell
az vm list -g acctestrg --query "[].{\"VM Name\":name}" -o table
```
6. Clean up resources
```shell
terraform plan -destroy -out main.destroy.tfplan
```
Then

```shell
terraform aplly  main.destroy.tfplan
```