#!/bin/bash

BINARY=regen
CHAIN_DIR=./data
CHAINID=regen-ica
GRPCPORT=9090
GRPCWEB=9091

echo "Starting $CHAINID in $CHAIN_DIR..."
echo "Creating log file at $CHAIN_DIR/$CHAINID.log"
$BINARY start --log_level trace --log_format json --minimum-gas-prices 0uregen --home $CHAIN_DIR/$CHAINID --pruning=nothing --grpc.address="0.0.0.0:$GRPCPORT" --grpc-web.address="0.0.0.0:$GRPCWEB" > $CHAIN_DIR/$CHAINID.log 2>&1 &
