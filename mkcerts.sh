#!/bin/sh

# Based on
# https://github.com/openssl/openssl/blob/master/demos/certs/mkcerts.sh

export CURVE=secp256k1


# Root CA: generate EC private key
openssl ecparam -genkey -name $CURVE -noout -out root-key.pem

# Root CA: create self-signed certificate from private key
openssl req -x509 -config openssl-ca.cnf \
    -key root-key.pem -out root-cert.pem -days 3650



# Intermediate CA: generate EC private key
openssl ecparam -genkey -name $CURVE -noout -out int-key.pem

# Intermediate CA: create CSR from private key
openssl req -new -config openssl-ca.cnf -key int-key.pem -out int-req.pem

# Intermediate CA: sign CSR with CA extensions
openssl x509 -req -in int-req.pem -CAkey root-key.pem -CA root-cert.pem -days 3650 \
    -extfile openssl-ca.cnf -extensions ca_extensions -CAcreateserial -out int-cert.pem

# Intermediate CA: delete CSR
rm int-req.pem



# Make full chain from root and intermediate CA certs
cat root-cert.pem int-cert.pem > fullchain.pem



# Server: generate EC private key
openssl ecparam -genkey -name $CURVE -noout -out server-key.pem

# Server: create CSR from private key
openssl req -new -config openssl-ca.cnf -key server-key.pem -out server-req.pem

# Server: sign CSR with DH extensions
openssl x509 -req -in server-req.pem -CAkey int-key.pem -CA int-cert.pem -days 3600 \
    -extfile openssl-ca.cnf -extensions dh_cert -CAcreateserial -out server-cert.pem

# Server: delete CSR
rm server-req.pem
