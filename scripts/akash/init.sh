#!/bin/bash

BINARY=akash
CHAIN_DIR=./data
CHAINID=akash-ica

VAL_MNEMONIC="clock post desk civil pottery foster expand merit dash seminar song memory figure uniform spice circle try happy obvious trash crime hybrid hood cushion"
WALLET_MNEMONIC_1="banner spread envelope side kite person disagree path silver will brother under couch edit food venture squirrel civil budget number acquire point work mass"
WALLET_MNEMONIC_2="veteran try aware erosion drink dance decade comic dawn museum release episode original list ability owner size tuition surface ceiling depth seminar capable only"
RLY_MNEMONIC="alley afraid soup fall idea toss can goose become valve initial strong forward bright dish figure check leopard decide warfare hub unusual join cart"

P2PPORT_1=16656
RPCPORT_1=26656
RESTPORT_1=1316
ROSETTA_1=8080

# Stop if it is already running 
if pgrep -x "$BINARY" >/dev/null; then
    echo "Terminating $BINARY..."
    killall $BINARY
fi

echo "Removing previous data..."
rm -rf $CHAIN_DIR/$CHAINID &> /dev/null

# Add directory for akash chain, exit if an error occurs
if ! mkdir -p $CHAIN_DIR/$CHAINID 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi


echo "Initializing $CHAINID..."
$BINARY init test --home $CHAIN_DIR/$CHAINID --chain-id=$CHAINID

echo "Adding genesis accounts..."
echo $VAL_MNEMONIC | $BINARY keys add val1 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test
echo $WALLET_MNEMONIC_1 | $BINARY keys add wallet1 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test
echo $WALLET_MNEMONIC_2 | $BINARY keys add wallet2 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test
echo $RLY_MNEMONIC | $BINARY keys add rly1 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test 

$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show val1 --keyring-backend test -a) 100000000000uakt  --home $CHAIN_DIR/$CHAINID
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show wallet1 --keyring-backend test -a) 100000000000uakt  --home $CHAIN_DIR/$CHAINID
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show wallet2 --keyring-backend test -a) 100000000000uakt  --home $CHAIN_DIR/$CHAINID
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show rly1 --keyring-backend test -a) 100000000000uakt  --home $CHAIN_DIR/$CHAINID

echo "Creating and collecting gentx..."
$BINARY gentx val1 7000000000uakt --home $CHAIN_DIR/$CHAINID --chain-id $CHAINID --keyring-backend test

echo "Changing defaults and ports in app.toml and config.toml files..."
sed -i -e 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT_1"'"#g' $CHAIN_DIR/$CHAINID/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:'"$RPCPORT_1"'"#g' $CHAIN_DIR/$CHAINID/config/config.toml
sed -i -e 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $CHAIN_DIR/$CHAINID/config/config.toml
sed -i -e 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $CHAIN_DIR/$CHAINID/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $CHAIN_DIR/$CHAINID/config/config.toml
sed -i -e 's/enable = false/enable = true/g' $CHAIN_DIR/$CHAINID/config/app.toml
sed -i -e 's/swagger = false/swagger = true/g' $CHAIN_DIR/$CHAINID/config/app.toml
sed -i -e 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$RESTPORT_1"'"#g' $CHAIN_DIR/$CHAINID/config/app.toml
sed -i -e 's#":8080"#":'"$ROSETTA_1"'"#g' $CHAIN_DIR/$CHAINID/config/app.toml
sed -i -e "s/stake/uakt/g" $CHAIN_DIR/$CHAINID/config/genesis.json

$BINARY collect-gentxs --home $CHAIN_DIR/$CHAINID


# Update host chain genesis to allow x/bank/MsgSend ICA tx execution
sed -i -e 's/\"allow_messages\":.*/\"allow_messages\": [\"\/cosmos.bank.v1beta1.MsgSend\",\"\/cosmos.staking.v1beta1.MsgDelegate\"]/g' $CHAIN_DIR/$CHAINID/config/genesis.json