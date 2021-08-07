#!/usr/bin/env sh

if [ ! -f "$HOME/ssl/rootCA.pem" ]; then
  openssl genrsa -out "$HOME/ssl/rootCA.key" 2048
  openssl req -x509 -new -nodes -key "$HOME/ssl/rootCA.key" -sha256 -days 1024 -out "$HOME/ssl/rootCA.pem" -subj "/C=US/ST=Texas/L=Denton/O=Brian LLC/OU=prod/CN=Brian LLC rootCA"
fi

cat > v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = hornsup
DNS.2 = localhost
EOF

COMMON_NAME=hornsup
SUBJECT="/C=US/ST=Texas/L=Denton/O=Brian LLC/OU=None/CN=$COMMON_NAME"
openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout hornsup.key -subj "$SUBJECT" -out hornsup.csr
openssl x509 -req -in hornsup.csr -CA "$HOME/ssl/rootCA.pem" -CAkey "$HOME/ssl/rootCA.key" -CAcreateserial -out hornsup.crt -days 365 -sha256 -extfile v3.ext

openssl pkcs12 -export -out hornsup.p12 -in hornsup.crt -inkey hornsup.key -name hornsup -password "pass:monday1"


# exporting to a der (cert)
# keytool -export -alias "${SERVERNAME}-${APP}" -file "$HOME/ssl/${SERVERNAME}-${APP}.der" -keystore "$HOME/ssl/${SERVERNAME}-${APP}-keystore.jks" -keypass "${KEYSTORE_PASSWORD}" -storepass "${TRUSTSTORE_PASSWORD}"

# exporting to a pem
# keytool -export -rfc -alias hornsup -file hornsup.crt -keystore hornsup.jks -keypass monday1 -storepass monday1
rm -rf hornsup.jks
keytool -importkeystore -srckeystore hornsup.p12 -srcstoretype PKCS12 -destkeystore hornsup.jks -deststoretype JKS -keypass monday1 -storepass monday1

# keytool -importkeystore -srckeystore hornsup.jks -destkeystore hornsup.jks -deststoretype pkcs12 

cp hornsup.p12 ~/projects/github.com/BitExplorer/raspi-finance-endpoint/src/main/resources/hornsup-raspi-finance-keystore.p12
cp hornsup.crt ~/projects/github.com/BitExplorer/raspi-finance-react/ssl/hornsup-raspi-finance-cert.pem
cp hornsup.key ~/projects/github.com/BitExplorer/raspi-finance-react/ssl/hornsup-raspi-finance-key.pem
cp hornsup.jks ~/projects/github.com/BitExplorer/raspi-finance-ratpack/src/ratpack/hornsup-raspi-finance.jks

exit 0
