# This is setup that you run interactively once (or occasionally), to obtain a
# token.
# This code should not run in the deployed setting.
# This code does not need to be deployed at all.

library(googlesheets4)

# create a folder for the auth-related files
dir.create(".secrets")

# we're expecting `NULL` here, which implies googlesheets4 will fall back to
# one of the built-in tidyverse oauth clients
gs4_oauth_client()

# indicate that we want to use a "web" oauth client, because that is what
# must be used on the *server* where we are deploying
options(gargle_oauth_client_type = "web")

# explicit auth with:
# * intended email (= user)
# * intended scopes
# * `use_oob = TRUE`: This is a clunkier process than the usual desktop
#   experience, but creates a token more suitable for the server.
gs4_auth(
  "jenny@posit.co",
  scopes = "spreadsheets.readonly",
  cache = FALSE,
  use_oob = TRUE
)

# confirm you are logged in with the intended identity
gs4_user()

# get the token, encrypt it, and write to file
token <- gs4_token()
if (inherits(token, "request")) {
  token <- token$auth_token
}

# the env var must already exist (specify the name of any env var here)
gargle::secret_write_rds(
  token,
  ".secrets/gs4-read-only-token.rds",
  "GOOGLEDRIVE_DEPLOY_DEMO_KEY"
)

# behold the encrypted token file
list.files(".secrets/")

# check that the `.rds` file can't be read by normal means
# this should be an error
readRDS(".secrets/gs4-read-only-token.rds")

# THE TOKEN SETUP IS DONE!
