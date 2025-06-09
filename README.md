# red-team-infra
This repository hosts Infrastructure-as-Code (IaC) to deploy various red team infrastructure, i.e., C2 servers, redirectors, etc.

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

### sliver
This deploys a sliver team server in AWS.

You can change the operator configuration profiles in sliver/roles/operators/files/main.yml. Simply add or remove operator names in the file.

Deploy by running:
```
cd ./sliver
terraform init
terrafrom apply
```

Connect to the sliver server with:
```
sliver-client import operator_configs/your/config/file
sliver-client
```
## What's Next
I plan to continue working on developing some redirectors next.
