message("working directory currently is ", getwd())
options(repos = "https://cran.rstudio.com")
if (!require(ini)) install.packages("ini")
if (!require(glue)) install.packages("glue")
if (!require(jsonlite)) install.packages("jsonlite")
if (!require(aws.signature)) install.packages("aws.signature")

the_region <- "us-east-1"

get_secret <- function(secret_id) {
  secrets <-
    system2("aws",
            c("secretsmanager", "get-secret-value", "--secret-id", secret_id, "--region", the_region, "--output", "json"),
            stdout = TRUE
            ) |>
    jsonlite::fromJSON()
  return(jsonlite::fromJSON(secrets$SecretString))
}

secrets <- list(
  ses = get_secret("saltdev-d1-ses-send-user-secret"),
  ## gh = get_secret("saltdev-d1-rcon-github"),
  db = get_secret("saltdev-d1-rcon-dbuser-secret")
)

d_ini <- ini::read.ini("./files/rstudio-connect.gcfg")

d_ini$SMTP$Host <- glue("email-smtp.{the_region}.amazonaws.com")
d_ini$SMTP$User <- secrets$ses$key
d_ini$SMTP$Password <-
  system2("./files/convert_smtp_password.py",
    c(secrets$ses$secret, the_region),
    stdout = TRUE
  )

d_ini$Postgres$URL <-
  glue::glue_data(secrets$db, "postgres://{username}@{host}/{dbname}") |>
  utils::URLencode()
d_ini$Postgres$Password <- glue::glue("\"{secrets$db$password}\"")

## d_ini$GitCredential$Username <- "CCHMC-SALT"
## d_ini$GitCredential$Password <- secrets$gh$SecretString

d_ini$Metrics$DataPath <-
  paste0("/reference-data/metrics/",
         system2("cat", "/etc/machine-id", stdout = TRUE))

## dir.create("/etc/rstudio-connect", showWarnings = FALSE)
ini::write.ini(d_ini, "/etc/rstudio-connect/rstudio-connect.gcfg")
