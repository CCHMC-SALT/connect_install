if (!require(ini)) install.packages("ini")
if (!require(glue)) install.packages("glue")
if (!require(jsonlite)) install.packages("jsonlite")
if (!require(aws.signature)) install.packages("aws.signature")

the_region <- "us-east-1"

get_secret <- function(secret_id) {
  secrets <-
    system2("aws",
      c(
        "secretsmanager",
        ## "--profile salty",
        "get-secret-value",
        "--secret-id", secret_id,
        "--region", the_region,
        "--output", "json"
      ),
      stdout = TRUE
    ) |>
    jsonlite::fromJSON()
  return(jsonlite::fromJSON(secrets$SecretString))
}

secrets <- list(
  ses = get_secret("saltdev-d1-ses-send-user-secret"),
  db = get_secret("saltdev-d1-rcon-dbuser-secret")
)

d_ini <- read.ini("/etc/rcon/rstudio-connect.gcfg")

d_ini$SMTP$Host <- glue("email-smtp.{the_region}.amazonaws.com")
d_ini$SMTP$User <- secrets$ses$key
d_ini$SMTP$Password <-
  system2("/etc/rcon/convert_smtp_password.py",
    c(secrets$ses$secret, the_region),
    stdout = TRUE
  )

d_ini$Postgres$URL <-
  glue_data(secrets$db, "postgres://{username}:{password}@{host}/{dbname}")

write.ini(d_ini, "files/rstudio-connect.gcfg")
