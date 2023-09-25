if (!require(ini)) install.packages("ini")
if (!require(glue)) install.packages("glue")
if (!require(jsonlite)) install.packages("jsonlite")

secrets <-
  system2("aws",
  c(
    "secretsmanager",
    "--profile salty",
    "get-secret-value",
    "--secret-id saltdev-d1-ses-send-user-secret",
    "--region us-east-1 --output json"
  ),
  stdout = TRUE
  ) |>
  jsonlite::fromJSON()

secrets <-
  secrets$SecretString |>
  jsonlite::fromJSON()

d_ini <- read.ini("files/rstudio-connect.gcfg")

d_ini$SMTP$User <- secrets$key
d_ini$SMTP$Host
d_ini$SMTP$Password

write.ini(d_ini, "files/rstudio-connect.gcfg")
file.show("files/rstudio-connect.gcfg")

d_ini$SMTP$Host
d_ini$SMTP$Port
d_ini$SMTP$Password

Sys.getenv("secrets_string")
