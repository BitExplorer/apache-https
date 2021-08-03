#!/usr/bin/env sh

openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -subj "/C=US/ST=Texas/L=Denton/O=Brian LLC/OU=dev/CN=rootCA"

exit 0
