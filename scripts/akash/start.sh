#!/bin/bash

BINARY=akash
CHAIN_DIR=./data
CHAINID=akash-ica
GRPCPORT=8090
GRPCWEB=8091

echo "Starting $CHAINID in $CHAIN_DIR..."
echo "Creating log file at $CHAIN_DIR/$CHAINID.log"
$BINARY start --log_format json --minimum-gas-prices 0uakt --home $CHAIN_DIR/$CHAINID --pruning=nothing --grpc.address="0.0.0.0:$GRPCPORT" --grpc-web.address="0.0.0.0:$GRPCWEB" > $CHAIN_DIR/$CHAINID.log 2>&1 &
