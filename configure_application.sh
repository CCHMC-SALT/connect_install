#! /bin/bash -xe

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".region")
ACCOUNTID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".accountId")
INSTANCEID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
ENVIRONMENTCODE=$(aws ec2 describe-instances --instance-id $INSTANCEID --region $REGION --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text | cut -d . -f 1)

getparameter() { 
  aws ssm get-parameter --region $REGION --name $1 | jq -r .Parameter.Value
}

# modify the custom template index.html to use the correct global site tag for google analytics


GTAG=$(getparameter /Infra/App/shiny/GoogleAnalyticsTag)

for TEMPLATEFILE in $(ls /etc/shinyproxy/templates/lungmap/*.html); do

  sed -i "s/#GoogleTag#/${GTAG}/g" $TEMPLATEFILE

done 




