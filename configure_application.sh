#! /bin/bash -xe

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".region")

getparameter() { 
  aws ssm get-parameter --region $REGION --name $1 | jq -r .Parameter.Value
}

# modify the custom template index.html to use the correct global site tag for google analytics


GTAG=$(getparameter /Infra/App/shiny/GoogleAnalyticsTag)

for TEMPLATEFILE in $(ls /etc/shinyproxy/templates/lungmap/*.html); do

  sed -i "s/#GoogleTag#/${GTAG}/g" $TEMPLATEFILE

done 




