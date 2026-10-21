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

# explicit auth with:
# * intended email (= user)
# * intended, minimal scopes
# * `cache = FALSE`: Because we will soon write the encrypted token to disk
#   ourselves (see below).
# No need to set `use_oob` or `gargle_oauth_client_type`. The deployed doc uses
# this stored token directly, so it never gets a new token or searches a cache,
# which is when those settings matter.
gs4_auth(
  "jenny@posit.co",
  scopes = "spreadsheets.readonly",
  cache = FALSE
)

# confirm you are logged in with the intended identity
gs4_user()

# get the token, encrypt it, and write to file
token <- gs4_token()
if (inherits(token, "request")) {
  token <- token$auth_token
}

# The env var must already exist!
# Specify the name of any env var here, but be consistent everywhere.
# Env var must exist, with same value, locally and on the server.
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
