# Installing Posit Connect as an Ec2LinuxAppStack

This code uses the [AppSpec 'hooks'](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-server) to deploy [Posit Connect](https://docs.posit.co/rsc/manual-install/) using AWS CodeDeploy. 

(Internal CCHMC documentation on Ec2LinuxAppStack: https://confluence.research.cchmc.org/pages/viewpage.action?spaceKey=AWSSIG&title=Ec2LinuxAppStack)

#### configuration notes

- check on preferences for email displays
- all emails, permissions requests, errors sent to SALT_Grant email, but also logging everything
- sitemap is enabled for public-facing content
- is 4 cores okay for make to use during R package installation?
- help with setting up authentication and email settings in config file
