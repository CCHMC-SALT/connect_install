#! /bin/bash -xe

# activate license
export RSC_LICENSE=`aws secretsmanager get-secret-value --secret-id RSC_LICENSE --region us-east-1 --output json --query "SecretString"`
/opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE

systemctl restart rstudio-connect



