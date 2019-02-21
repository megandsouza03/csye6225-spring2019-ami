# AWS AMI for CSYE 6225

## Team Information

| Name | NEU ID | Email Address |
| --- | --- | --- |
| Vishnu Prasad Maruthi|001200200 |maruthi.v@husky.neu.edu |
| Vinyas Kaushik Tumakunte Raghavendrarao|001216716|tumakunteraghaven.v@husky.neu.edu|
| Vikram Ramesh|001856230|ramesh.vik@husky.neu.edu|
| Megan Simone Theresa Dsouza|001837524|dsouza.me@husky.neu.edu |

## Validate Template

```
packer validate centos-ami-template.json
```

## Build AMI

```
packer build \
    -var 'aws_access_key=REDACTED' \
    -var 'aws_secret_key=REDACTED' \
    -var 'aws_region=us-east-1' \
    -var 'subnet_id=REDACTED' \
    centos-ami-template.json
```
