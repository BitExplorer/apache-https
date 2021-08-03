#!/usr/bin/env sh

if [ ! -f "$HOME/ssl/rootCA.pem" ]; then
  openssl genrsa -out rootCA.key 2048
  openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -subj "/C=US/ST=Texas/L=Denton/O=Brian LLC/OU=dev/CN=rootCA"
fi

cat > v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = hornsup
EOF

COMMON_NAME=hornsup
SUBJECT="/C=US/ST=Texas/L=Denton/O=Brian LLC/OU=None/CN=$COMMON_NAME"
openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout hornsup.key -subj "$SUBJECT" -out hornsup.csr
openssl x509 -req -in hornsup.csr -CA "$HOME/ssl/rootCA.pem" -CAkey "$HOME/ssl/rootCA.key" -CAcreateserial -out hornsup.crt -days 365 -sha256 -extfile v3.ext

openssl pkcs12 -export -out hornsup.p12 -in hornsup.crt -inkey hornsup.key -name hornsup -password "pass:monday1"

cp hornsup.p12 ~/projects/raspi-finance-endpoint/src/main/resources/hornsup-raspi-finance-keystore.p12
cp hornsup.crt ~/projects/raspi-finance-react/ssl/hornsup-raspi-finance-cert.pem
cp hornsup.key ~/projects/raspi-finance-react/ssl/hornsup-raspi-finance-key.pem

exit 0
