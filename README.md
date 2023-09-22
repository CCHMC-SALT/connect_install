# Installing Posit Connect as an Ec2LinuxAppStack

## About

This code uses the [AppSpec 'hooks'](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-server) to deploy [Posit Connect](https://docs.posit.co/rsc/manual-install/) using AWS CodeDeploy. 

(Internal CCHMC documentation on Ec2LinuxAppStack: https://confluence.research.cchmc.org/pages/viewpage.action?spaceKey=AWSSIG&title=Ec2LinuxAppStack)

## Deploying

- `make bundle` to update the `connect_install.zip` file
- send `connect_install.zip` to `s3://XXXXX` to trigger code deploy
