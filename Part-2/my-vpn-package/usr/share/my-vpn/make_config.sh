#!/bin/bash

# check args
if [ $# -ne 1 ]; then
    echo "Usage: $0 <client-name>" >&2
    echo "Example: $0 client-2" >&2
    exit 1
fi

CLIENT_NAME=$1
KEY_DIR=~/clients/keys
OUTPUT_DIR=~/clients/files
BASE_CONFIG=~/clients/base.conf

# Is dir exist
if [ ! -d "$KEY_DIR" ]; then
    echo "Error: Directory $KEY_DIR does not exist" >&2
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Directory $OUTPUT_DIR does not exist" >&2
    exit 1
fi

# Check files
if [ ! -f "$BASE_CONFIG" ]; then
    echo "Error: Base config file $BASE_CONFIG does not exist" >&2
    exit 1
fi

if [ ! -f "$KEY_DIR/ca.crt" ]; then
    echo "Error: CA certificate $KEY_DIR/ca.crt does not exist" >&2
    exit 1
fi

if [ ! -f "$KEY_DIR/$CLIENT_NAME.crt" ]; then
    echo "Error: Client certificate $KEY_DIR/$CLIENT_NAME.crt does not exist" >&2
    exit 1
fi

if [ ! -f "$KEY_DIR/$CLIENT_NAME.key" ]; then
    echo "Error: Client key $KEY_DIR/$CLIENT_NAME.key does not exist" >&2
    exit 1
fi

if [ ! -f "$KEY_DIR/ta.key" ]; then
    echo "Error: TLS key $KEY_DIR/ta.key does not exist" >&2
    exit 1
fi

cat ${BASE_CONFIG} \
<(echo -e '<ca>') \
${KEY_DIR}/ca.crt \
<(echo -e '</ca>\n<cert>') \
${KEY_DIR}/${CLIENT_NAME}.crt \
<(echo -e '</cert>\n<key>') \
${KEY_DIR}/${CLIENT_NAME}.key \
<(echo -e '</key>\n<tls-crypt>') \
${KEY_DIR}/ta.key \
<(echo -e '</tls-crypt>') \
> ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn || { echo "Failed to create ${CLIENT_NAME}.ovpn" >&2; exit 1; }

echo "Client configuration ${CLIENT_NAME}.ovpn created successfully"
exit 0
