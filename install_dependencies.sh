#! /bin/bash -xe

apt-get update -qq

# install versions of R
R_VERSION=3.6.2

R_FILE="r-${R_VERSION}_1_amd64.deb"

curl -O https://cdn.rstudio.com/r/ubuntu-2204/pkgs/r-${R_VERSION}_1_amd64.deb
DEBIAN_FRONTEND=noninteractive gdebi --non-interactive r-${R_VERSION}_1_amd64.deb
rm -f ./r-${R_VERSION}_1_amd64.deb

R_VERSION_ALT=4.1.0
    curl -O https://cdn.rstudio.com/r/ubuntu-2204/pkgs/r-${R_VERSION_ALT}_1_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive r-${R_VERSION_ALT}_1_amd64.deb && \
    rm -f ./r-${R_VERSION_ALT}_1_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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



# install versions of python
PYTHON_VERSION=3.9.5
apt-get update -qq \
    && curl -O https://cdn.rstudio.com/python/ubuntu-2204/pkgs/python-${PYTHON_VERSION}_1_amd64.deb \
    && DEBIAN_FRONTEND=noninteractive gdebi -n python-${PYTHON_VERSION}_1_amd64.deb \
    && /opt/python/"${PYTHON_VERSION}"/bin/pip install --upgrade pip setuptools wheel \
    && rm -f ./python-${PYTHON_VERSION}_1_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

PYTHON_VERSION_ALT=3.8.10
apt-get update -qq \
    && curl -O https://cdn.rstudio.com/python/ubuntu-2204/pkgs/python-${PYTHON_VERSION_ALT}_1_amd64.deb \
    && DEBIAN_FRONTEND=noninteractive gdebi -n python-${PYTHON_VERSION_ALT}_1_amd64.deb \
    && /opt/python/"${PYTHON_VERSION_ALT}"/bin/pip install --upgrade pip setuptools wheel \
    && rm -f ./python-${PYTHON_VERSION_ALT}_1_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install quarto
QUARTO_VERSION=1.3.340
curl -L -o /quarto.tar.gz "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" \
    && mkdir -p /opt/quarto/${QUARTO_VERSION} \
    && tar -zxvf quarto.tar.gz -C "/opt/quarto/${QUARTO_VERSION}" --strip-components=1 \
    && rm -f /quarto.tar.gz

# install connect
RSC_VERSION=2023.06.0
apt-get update --fix-missing \
    && RSC_VERSION_URL=$(echo -n "${RSC_VERSION}" | sed 's/+/%2B/g') \
    && curl -L -o rstudio-connect.deb "https://cdn.rstudio.com/connect/$(echo $RSC_VERSION | sed -r 's/([0-9]+\.[0-9]+).*/\1/')/rstudio-connect_${RSC_VERSION_URL}~ubuntu22_amd64.deb" \
    && gdebi -n rstudio-connect.deb \
    && rm -rf rstudio-connect.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## verify connect signature
# gpg --keyserver keyserver.ubuntu.com --recv-keys 3F32EE77E331692F
# dpkg-sig --verify rstudio-connect_2023.06.0_amd64.deb


