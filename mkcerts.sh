#!/bin/sh

# Based on
# https://github.com/openssl/openssl/blob/master/demos/certs/mkcerts.sh

# Root CA: create certificate directly
openssl req -config openssl-ca.cnf -x509 -nodes \
    -keyout root.pem -out root.pem -newkey rsa:2048 -days 3650

# Intermediate CA: request first
openssl req -config openssl-ca.cnf -nodes \
    -keyout intkey.pem -out intreq.pem -newkey rsa:2048

# Sign request: CA extensions
openssl x509 -req -in intreq.pem -CA root.pem -days 3600 \
    -extfile openssl-ca.cnf -extensions ca_extensions -CAcreateserial -out intca.pem


# Server certificate: create request first
openssl req -config openssl-ca.cnf -nodes \
    -keyout skey.pem -out req.pem -newkey rsa:1024

# Sign request: end entity extensions
openssl x509 -req -in req.pem -CA intca.pem -CAkey intkey.pem -days 3600 \
    -extfile openssl-ca.cnf -extensions usr_cert -CAcreateserial -out server.pem


openssl ecparam -genkey -name secp256k1 -noout -out secp256k1-key.pem

openssl req -config openssl-ca.cnf -new \
    -key secp256k1-key.pem -out ecdh-req.pem

openssl x509 -req -in ecdh-req.pem -CAkey intkey.pem -CA intca.pem -days 3600 \
    -extfile openssl-ca.cnf -extensions dh_cert -CAcreateserial -out ecdhserver.pem
