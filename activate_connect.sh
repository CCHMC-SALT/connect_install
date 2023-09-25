#! /bin/bash -xe

# activate license
export RSC_LICENSE=`aws secretsmanager get-secret-value --secret-id saltdev-d1-rcon-activate-connect-secret --region us-east-1 --output json --query "SecretString"`
/opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE

systemctl restart rstudio-connect

# add SMTP email credentials to rcon gcfg file
R -e "source('./update_rcon_ini.R')"

systemctl restart rstudio-connect
