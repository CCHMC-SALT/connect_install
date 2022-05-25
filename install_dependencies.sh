#! /bin/bash -xe

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".region")
ACCOUNTID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".accountId")
INSTANCEID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

getparameter() { 
  aws ssm get-parameter --region $REGION --name $1 | jq -r .Parameter.Value
}

#
# mount the efs resources for reference data
# 

echo "Mounting reference data filesystem..."

FSID=$(getparameter /Infra/App/shiny/EfsFsId)
MOUNTPOINT="/reference-data"

if [ ! -d $MOUNTPOINT ]; then
  mkdir $MOUNTPOINT
fi
 
if ! grep $FSID /etc/fstab > /dev/null; then
  echo "${FSID}:/ ${MOUNTPOINT} efs _netdev,tls 0 0" >> /etc/fstab
fi
 
if ! mount | grep $MOUNTPOINT > /dev/null; then
  mount $MOUNTPOINT
fi

#
# install docker
#

echo "Installing docker..."

yum update -y

yum install java-openjdk -y
amazon-linux-extras install docker -y

service docker start

systemctl enable docker

if [ ! -d /etc/systemd/system/docker.service.d/ ]; then
  mkdir /etc/systemd/system/docker.service.d/
fi

cat << 'EOF' > /etc/systemd/system/docker.service.d/override.conf

[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:// -D -H tcp://127.0.0.1:2375

EOF

systemctl daemon-reload
systemctl restart docker

#
# pull rshiny images
#

echo "Pulling rshiny images..."

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com 

for URI in $(aws ecr describe-repositories --repository-names $(getparameter /Infra/App/shiny/RepoList) --region $REGION | jq -r .repositories[].repositoryUri); do
  docker pull $URI
  IMAGE=${URI##*/}
  docker image tag ${URI}:latest ${IMAGE}:latest
done

#
# install and configure shinyproxy
#

echo "Installing and configuring shinyproxy..."

wget -P /tmp/ https://www.shinyproxy.io/downloads/shinyproxy_2.6.0_x86_64.rpm

rpm --install /tmp/shinyproxy_2.6.0_x86_64.rpm

systemctl daemon-reload
systemctl stop shinyproxy

usermod -a -G docker shinyproxy

echo "Installing Prometheus monitoring"

OWD=$PWD

if [ ! -f /etc/yum.repos.d/preometheus.repo ]; then

cat << EOF > /etc/yum.repos.d/prometheus.repo
[prometheus]
name=prometheus
baseurl=https://packagecloud.io/prometheus-rpm/release/el/7/x86_64
repo_gpgcheck=1
enabled=1
gpgkey=https://packagecloud.io/prometheus-rpm/release/gpgkey
       https://raw.githubusercontent.com/lest/prometheus-rpm/master/RPM-GPG-KEY-prometheus-rpm
gpgcheck=1
metadata_expire=300
EOF

fi

yum update -y

yum install prometheus2 -y

cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'shinyproxy'
    metrics_path: '/actuator/prometheus'
    static_configs:
      # note: this is the port of ShinyProxy Actuator services, not the port of Prometheus which is by default also 9090
      - targets: ['localhost:9090']
EOF

echo "PROMETHEUS_OPTS='--config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data --web.console.libraries=/usr/share/prometheus/console_libraries --web.console.templates=/usr/share/prometheus/consoles --web.listen-address=0.0.0.0:7070'" > /etc/default/prometheus

systemctl start prometheus

echo "Creating cloudwatch export script"

cat << 'EOF' > /opt/shinymon.sh
#!/bin/bash
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".region")
ACCOUNTID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".accountId")
INSTANCEID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
ASGNAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCEID} --region ${REGION} | jq -r '.AutoScalingInstances[].AutoScalingGroupName')
for APPNAME in $(curl -s http://localhost:7070/api/v1/query?query=absolute_apps_running | jq -r '.data.result[].metric.spec_id'); do
        TIMESTAMP=$(date +%s)
        VALUE=$(curl -s http://localhost:7070/api/v1/query?query=absolute_apps_running%7Bspec_id=%22${APPNAME}%22%7D | jq -r '.data.result[].value[1]')
        aws cloudwatch put-metric-data --namespace ShinyApp --metric-name AppsRunning --unit Count --value ${VALUE} --dimensions InstanceId=${INSTANCEID},AppName=${APPNAME} --region ${REGION} --timestamp ${TIMESTAMP}
        aws cloudwatch put-metric-data --namespace ShinyApp --metric-name AppsRunning --unit Count --value ${VALUE} --dimensions AutoScalingGroupName=${ASGNAME},AppName=${APPNAME} --region ${REGION} --timestamp ${TIMESTAMP}
done
EOF

chmod 755 /opt/shinymon.sh

if ! grep shinymon /etc/crontab > /dev/null; then
  echo '* * * * * root /opt/shinymon.sh' >> /etc/crontab
fi





