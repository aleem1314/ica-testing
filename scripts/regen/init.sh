#!/bin/bash

BINARY=regen
CHAIN_DIR=./data
CHAINID=regen-ica

VAL_MNEMONIC="angry twist harsh drastic left brass behave host shove marriage fall update business leg direct reward object ugly security warm tuna model broccoli choice"
WALLET_MNEMONIC_1="vacuum burst ordinary enact leaf rabbit gather lend left chase park action dish danger green jeans lucky dish mesh language collect acquire waste load"
WALLET_MNEMONIC_2="open attitude harsh casino rent attitude midnight debris describe spare cancel crisp olive ride elite gallery leaf buffalo sheriff filter rotate path begin soldier"
RLY_MNEMONIC="record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"

P2PPORT_1=16657
RPCPORT_1=26657
RESTPORT_1=1317
ROSETTA_1=8081

# Stop if it is already running 
if pgrep -x "$BINARY" >/dev/null; then
    echo "Terminating $BINARY..."
    killall $BINARY
fi

echo "Removing previous data..."
rm -rf $CHAIN_DIR/$CHAINID &> /dev/null

# Add directory for regen chain, exit if an error occurs
if ! mkdir -p $CHAIN_DIR/$CHAINID 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi


echo "Initializing $CHAINID..."
$BINARY init test --home $CHAIN_DIR/$CHAINID --chain-id=$CHAINID

echo "Adding genesis accounts..."
echo $VAL_MNEMONIC | $BINARY keys add val2 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test
echo $WALLET_MNEMONIC_1 | $BINARY keys add wallet3 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test
echo $WALLET_MNEMONIC_2 | $BINARY keys add wallet4 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test
echo $RLY_MNEMONIC | $BINARY keys add rly2 --home $CHAIN_DIR/$CHAINID --recover --keyring-backend=test 

$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show val2 --keyring-backend test -a) 100000000000uregen  --home $CHAIN_DIR/$CHAINID
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show wallet3 --keyring-backend test -a) 100000000000uregen  --home $CHAIN_DIR/$CHAINID
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show wallet4 --keyring-backend test -a) 100000000000uregen  --home $CHAIN_DIR/$CHAINID
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID keys show rly2 --keyring-backend test -a) 100000000000uregen  --home $CHAIN_DIR/$CHAINID

echo "Creating and collecting gentx..."
$BINARY gentx val2 7000000000uregen --home $CHAIN_DIR/$CHAINID --chain-id $CHAINID --keyring-backend test

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
sed -i -e "s/stake/uregen/g" $CHAIN_DIR/$CHAINID/config/genesis.json

$BINARY collect-gentxs --home $CHAIN_DIR/$CHAINID


# Update host chain genesis to allow x/bank/MsgSend and x/staking/MsgDelegate ICA tx execution
sed -i -e 's/\"allow_messages\":.*/\"allow_messages\": [\"\/cosmos.bank.v1beta1.MsgSend\",\"\/cosmos.staking.v1beta1.MsgDelegate\"]/g' $CHAIN_DIR/$CHAINID/config/genesis.json