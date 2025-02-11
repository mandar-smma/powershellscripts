# full decoding (including signature verification) of the token
# pip install pyjwt then pip install cryptography
import jwt
import requests
from cryptography.x509 import load_pem_x509_certificate
from cryptography.hazmat.backends import default_backend

PEMSTART = '-----BEGIN CERTIFICATE-----\n'
PEMEND = '\n-----END CERTIFICATE-----\n'

# Get the Microsoft Azure public key.
def get_public_key_for_token(kid):
  response = requests.get(
    'https://login.microsoftonline.com/common/.well-known/openid-configuration',
  ).json()

  jwt_uri = response['jwks_uri']
  response_keys = requests.get(jwt_uri).json()
  pubkeys = response_keys['keys']

  public_key = ''

  for key in pubkeys:
    # Find the key that matches the kid in the token's header.
      if key['kid'] == kid:
        # Construct the public key object.
        mspubkey = str(key['x5c'][0])
        cert_str = PEMSTART + mspubkey + PEMEND
        cert_obj = load_pem_x509_certificate(bytes(cert_str, 'ascii'), default_backend())
        public_key = cert_obj.public_key()

  return public_key

# Decode the given <ms-entra-id> token which is received in Oauth process
def aad_access_token_decoder(access_token):
  header = jwt.get_unverified_header(access_token)
  public_key = get_public_key_for_token(header['kid'])
  decoded = jwt.decode(
    access_token,
    key = public_key,
    algorithms = 'RS256',
    audience = '<AnyAzResourceId-resource-id>')

  for key in decoded.keys():
    print(f"{key}: {str(decoded[key])}")