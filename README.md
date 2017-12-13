# Terraform Microsoft AD Demo

A proof of concept of deploying a highly available, scalable Microsoft Active Directory infrastructure in AWS using AWS Directory Services.

AWS Directory Services provides the Active Directory in multiple subnets in different availability zones to achieve high availability. After the AD is deployed, we can only interact with it through a Windows machine (I call it "AD Writer") that has joined the domain.

In this proof of concept, Terraform is used to orchestrate the deployment of the Active Directory and the AD Writer machine.

## Usage
```bash
AWS_ACCESS_KEY_ID=xx AWS_SECRET_ACCESS_KEY=yy terraform apply
```
The ad takes quite a while to start (around **23 minutes**).

When its all done it should output the addresses for the machines it's made and also the Admin password
The Windows box you can RDP to, the linux machines you can ssh to like: `ssh ec2-XXX-XXX-XXX-XXX.eu-west-2.compute.amazonaws.com -l admin@myapp.com`


## TODO
- [x] Another VPC with a machine in it that auths over a peer to the AD
- [x] Another VPC with a windows machine that auths over the peering
- [x] RHEL machine auto provisioning
- [x] Ubuntu machine auto provisioning
- [ ] Make a module to a lot of this heavy lifting and reference it here

## Things you should do
- Keep the admin credentials in KMS rather than terraform state
- Make an AD user with limited access that can just add computers to the AD rather than use the admin account which is considered bad practice.
- Find someway to remove computers from the AD when they go away

## Acknowledgements
This is based on [Tony P. Hadimulyono](https://github.com/tonyprawiro)'s [Blog post](https://medium.com/@tonyprawiro/deploying-windows-ad-in-aws-using-aws-directory-service-and-terraform-6141c819592f) and [GitHub Repo](https://github.com/tonyprawiro/aws-msad-terraform)