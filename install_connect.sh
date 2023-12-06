#! /bin/bash -xe

DEBIAN_FRONTEND=noninteractive 
apt-get update -qq
apt-get -y install curl gdebi-core

# install versions of R
for R_VERSION in 3.6.3 4.0.5 4.1.3 4.2.3 4.3.1; do
    curl -O https://cdn.rstudio.com/r/ubuntu-2204/pkgs/r-${R_VERSION}_1_amd64.deb
    gdebi --non-interactive r-${R_VERSION}_1_amd64.deb
    rm -f ./r-${R_VERSION}_1_amd64.deb
done

# install suggested system libraries for R packages
apt install -y \
    tcl tk tk-dev tk-table default-jdk libxml2-dev \
    libssl-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev \
    git make libfontconfig1-dev cmake libsodium-dev \
    libcairo2-dev libpng-dev libjpeg-dev \
    libmysqlclient-dev unixodbc-dev libicu-dev libtiff-dev zlib1g-dev \
    imagemagick libmagick++-dev gsfonts libcurl4-openssl-dev \
    libglu1-mesa-dev libgl1-mesa-dev libssh2-1-dev libudunits2-dev perl \
    libgdal-dev gdal-bin libgeos-dev libproj-dev libsqlite3-dev \
    python3 libglpk-dev libgmp3-dev libnode-dev

# # install versions of python
# for PYTHON_VERSION in 3.8.10 3.9.5; do
#     curl -O https://cdn.rstudio.com/python/ubuntu-2204/pkgs/python-${PYTHON_VERSION}_1_amd64.deb
#     gdebi --non-interactive python-${PYTHON_VERSION}_1_amd64.deb
#     /opt/python/"${PYTHON_VERSION}"/bin/pip install --upgrade pip setuptools wheel
#     rm -f ./python-${PYTHON_VERSION}_1_amd64.deb
# done

# install quarto
# QUARTO_VERSION=1.3.340
# curl -L -o /quarto.tar.gz "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
# mkdir -p /opt/quarto/${QUARTO_VERSION}
# tar -zxvf quarto.tar.gz -C "/opt/quarto/${QUARTO_VERSION}" --strip-components=1
# rm -f /quarto.tar.gz

# install connect
curl -O https://cdn.rstudio.com/connect/2023.09/rstudio-connect_2023.09.0~ubuntu22_amd64.deb
gdebi --non-interactive rstudio-connect_2023.09.0~ubuntu22_amd64.deb

# mount efs
getssm() {
        aws ssm get-parameter --region us-east-1 --name $1 | jq -r '.Parameter.Value'
        }

# mount efs resource for Server.DataDir
FSID=$(getssm /Infra/App/rcon/EfsFsId)
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

