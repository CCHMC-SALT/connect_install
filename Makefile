bundle: activate_connect.sh appspec.yml install_connect.sh start_service.sh stop_service.sh files/rstudio-connect.gcfg update_rcon_ini.R convert_smtp_password.py
	zip -v rcon.zip activate_connect.sh appspec.yml install_connect.sh start_service.sh stop_service.sh files/rstudio-connect.gcfg update_rcon_ini.R convert_smtp_password.py

deploy: rcon.zip
	aws s3 --profile salty cp rcon.zip s3://saltdev-d1-codedeploy/rcon/rcon.zip

shell:
	aws ssm --profile salty start-session --target i-09b52fa9c80bdeadb


