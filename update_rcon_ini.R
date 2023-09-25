if (!require(ini)) install.packages("ini")
if (!require(glue)) install.packages("glue")
if (!require(jsonlite)) install.packages("jsonlite")
if (!require(aws.signature)) install.packages("aws.signature")

the_region <- "us-east-1"

secrets <-
  system2("aws",
  c(
    "secretsmanager",
    ## "--profile salty",
    "get-secret-value",
    "--secret-id", "saltdev-d1-ses-send-user-secret",
    "--region", the_region,
    "--output", "json"
  ),
  stdout = TRUE
  ) |>
  jsonlite::fromJSON()

secrets <-
  secrets$SecretString |>
  jsonlite::fromJSON()

d_ini <- read.ini("files/rstudio-connect.gcfg")

d_ini$SMTP$Host <- glue("email-smtp.{the_region}.amazonaws.com")
d_ini$SMTP$User <- secrets$key
# convert secret key to SMTP password using python script from aws
d_ini$SMTP$Password <- system2("./convert_smtp_password.py", c(secrets$secret, the_region), stdout = TRUE)

write.ini(d_ini, "files/rstudio-connect.gcfg")
