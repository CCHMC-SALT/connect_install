bundle: activate_connect.sh appspec.yml install_connect.sh start_service.sh stop_service.sh files/rstudio-connect.gcfg
	zip -v rcon.zip activate_connect.sh appspec.yml install_connect.sh start_service.sh stop_service.sh files/rstudio-connect.gcfg

deploy: rcon.zip
	aws s3 --profile salty cp rcon.zip s3://saltdev-d1-codedeploy/rcon/rcon.zip
