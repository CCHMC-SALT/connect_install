rcon.zip: activate_connect.sh appspec.yml install_connect.sh start_service.sh stop_service.sh files/rstudio-connect.gcfg files/update_rcon_ini.R files/convert_smtp_password.py
	rm rcon.zip && zip -v rcon.zip activate_connect.sh appspec.yml install_connect.sh start_service.sh stop_service.sh files/rstudio-connect.gcfg files/update_rcon_ini.R files/convert_smtp_password.py

deploy: rcon.zip
	aws s3 --profile salty cp rcon.zip s3://saltdev-d1-codedeploy/rcon/rcon.zip

shell:
	aws ssm --profile salty start-session --target i-09ecc8c00002b56b9


