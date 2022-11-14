#!/bin/bash
set -e

# Load shell variables
. ./scripts/hermes/variables.sh

### Configure the clients and connection
echo "Initiating connection handshake..."
$HERMES_BINARY -c $CONFIG_DIR create connection akash-ica regen-ica

sleep 2