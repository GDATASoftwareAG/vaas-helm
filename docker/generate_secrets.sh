#!/usr/bin/env bash

# Generate private key and certificate
echo "Generate private key and certificate"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert.key -out cert.crt -subj "/CN=localhost"
echo "Certificate and key generated"

# Convert certificate to single line
CERT_ONE_LINE=$(awk 'NF {sub(/\r/, ""); printf "%s\\n", $0;}' cert.crt)
# Convert key to single line
KEY_ONE_LINE=$(awk 'NF {sub(/\r/, ""); printf "%s\\n", $0;}' cert.key)

# Write the secrets to the .env file
sed -i "s|<<ENCRYPTIONCERTIFICATE__CRT>>|$CERT_ONE_LINE|g" ./mini-oidc.secrets.env
sed -i "s|<<SIGNINGCERTIFICATE__CRT>>|$CERT_ONE_LINE|g" ./mini-oidc.secrets.env
sed -i "s|<<ENCRYPTIONCERTIFICATE__KEY>>|$KEY_ONE_LINE|g" ./mini-oidc.secrets.env
sed -i "s|<<SIGNINGCERTIFICATE__KEY>>|$KEY_ONE_LINE|g" ./mini-oidc.secrets.env

VAAS_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
sed -i "s|<<VAAS_PASSWORD>>|${VAAS_PASSWORD}|g" ./mini-oidc.secrets.env

sed -i "s|<<JWTSETTINGS__SECRET>>|$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)|g" ./gateway.secrets.env
echo "Secrets written to .env files"

echo "CLIENT_SECRET for sdk usage: ${VAAS_PASSWORD}"

# Clean up
rm cert.key cert.crt




