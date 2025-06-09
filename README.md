# red-team-infra
This repository hosts Infrastructure-as-Code (IaC) to deploy various red team infrastructure, i.e., C2 servers, redirectors, etc.
## Requirements
For this code to work as it is written, you will need the following:
- AWS Account
- Cloudflare registered domain
## Getting Started
### Environment Variables
Set AWS credentials:
```
export AWS_ACCESS_KEY_ID=
```
```
export AWS_SECRET_ACCESS_KEY=
```
Set Cloudflare API token:
```
export CLOUDFLARE_API_TOKEN=
```
### AWS Keypairs
Create a keypair in AWS and make sure the "aws_key_pair" and "ssh_key_path" variables are correct. You can create a file named "variables.auto.tfvars" and set them there:
```
aws_key_pair    =   "test"
ssh_key_path    = "~/.ssh/test.pem"
```
### Ansible
Download anisble collections:
```
ansible-galaxy collection install --requirements-file ./sliver/ansible/requirements.yml
```
## sliver
Deploys a sliver team server in AWS.
### Setup
Set all variables to your specifications in variables.auto.tfvars.

You can change the operator configuration profiles in sliver/roles/operators/files/main.yml. Simply add or remove operator names in the file.
### Deployment
Deploy by running:
```
cd ./sliver
terraform init
terrafrom apply
```
### Usage
Connect to the sliver server with:
```
sliver-client import operator_configs/your/config/file
sliver-client
```
## apache_redirector
Deploys an EC2 instance running an apache2 web server. Uses mod_rewrite rules to send all traffic to google.com unless it using a specified User-Agent.
### Setup
Set all variables to your specifications in variables.auto.tfvars.
### Deployment
Deploy by running:
```
cd ./apache_redirector
terraform init
terrafrom apply
```
## What's Next
- Improvements to apache_redirector
- Better documentation and guidance
- nginx_redirector
