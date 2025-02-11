#  Configure an app in Azure portal and get Application (client) ID, copy existing Directory (tenant) ID and the  Redirect URI http://localhost.com

# pip install msal
from msal import PublicClientApplication
import sys

# You can hard-code the registered app's client ID and tenant ID here,
# or you can provide them as command-line arguments to this script.
client_id = '<client-id>'
tenant_id = '<tenant-id>'
# refresh_token = '<refresh-token>'

# Modify this variable and use the programmatic ID for the concerned resource (ex: Functions, Sql Server) and append '/.default'.
scopes = [ '2ff814a6-3304-4ab8-85cb-oi0e6f879c1d/.default' ]

# Check for too few or too many command-line arguments.
if (len(sys.argv) > 1) and (len(sys.argv) != 3):
  print("Usage: get-tokens.py <client ID> <tenant ID>")
  exit(1)

# If the registered app's client ID and tenant ID are provided as
# command-line variables, set them here.
if len(sys.argv) > 1:
  client_id = sys.argv[1]
  tenant_id = sys.argv[2]

app = PublicClientApplication(
  client_id = client_id,
  authority = "https://login.microsoftonline.com/" + tenant_id
)

acquire_tokens_result = app.acquire_token_interactive(
  scopes = scopes
)

# acquire_tokens_result = app.acquire_token_by_refresh_token(
#   refresh_token = refresh_token,
#   scopes = scope
# )

if 'error' in acquire_tokens_result:
  print("Error: " + acquire_tokens_result['error'])
  print("Description: " + acquire_tokens_result['error_description'])
else:
  print("Access token:\n")
  print(acquire_tokens_result['access_token'])
  print("\nRefresh token:\n")
  print(acquire_tokens_result['refresh_token'])

# by curl 
# 1. https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize?client_id=<client-id>
# &response_type=code
# &redirect_uri=<redirect-uri>
# &response_mode=query
# &scope=2ff814a6-3304-4ab8-85cb-cd0e6f879c1d%2F.default
# &state=<state>

#2. curl -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
# https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token \
# -d 'client_id=<client-id>' \
# -d 'scope=2ff814a6-3304-4ab8-85cb-oi0e6f879c1d%2F.default' \
# -d 'code=<authorization-code>' \
# -d 'redirect_uri=<redirect-uri>' \
# -d 'grant_type=authorization_code' \
# -d 'state=<state>'