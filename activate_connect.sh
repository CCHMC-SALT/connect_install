#! /bin/bash -xe

# activate license
/opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE

systemctl restart rstudio-connect



