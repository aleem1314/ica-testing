# Interchain Accounts Testing

## Setup

1. Clone Akash repository and build the application binary

```bash
git clone https://github.com/ovrclk/akash.git
cd akash
git checkout v0.18.0

make install
```

2. Clone Regen repository and build the application binary

```bash
git clone https://github.com/regen-network/regen-ledger.git
cd regen-ledger
git checkout v5.0.0-beta1

make install
```

3. Download and install an Hermes relayer.

```bash
cargo install --version 0.15.0 ibc-relayer-cli --bin hermes --locked
```

4. Bootstrap both chains, configure the relayer and create an IBC connection (on top of clients that are created as well)
```bash
# hermes
make init-hermes
```

5. Start the relayer
```bash
#hermes
make start-hermes
```

## Demo

**NOTE:** For the purposes of this demo the setup scripts have been provided with a set of hardcoded mnemonics that generate deterministic wallet addresses used below.

```bash
# Store the following account addresses within the current shell env
export WALLET_1=$(akash keys show wallet1 -a --keyring-backend test --home ./data/akash-ica) && echo $WALLET_1;
export WALLET_2=$(akash keys show wallet2 -a --keyring-backend test --home ./data/akash-ica) && echo $WALLET_2;
export WALLET_3=$(regen keys show wallet3 -a --keyring-backend test --home ./data/regen-ica) && echo $WALLET_3;
export WALLET_4=$(regen keys show wallet4 -a --keyring-backend test --home ./data/regen-ica) && echo $WALLET_4;
```

### Registering an Interchain Account via IBC

Register an Interchain Account using the `intertx register` cmd. 
Here the message signer is used as the account owner.

```bash
# Register an interchain account on behalf of WALLET_3 where chain akash-ica is the interchain accounts host
regen tx intertx register --from=$WALLET_3 --connection-id =connection-0 --version='{"version":"ics27-1","tx_type":"sdk_multi_msg","encoding":"proto3","host_connection_id":"connection-0","controller_connection_id":"connection-0","address":"regen14zs2x38lmkw4eqvl3lpml5l8crzaxn6mpvh79z"}' --chain-id regen-ica --home ./data/regen-ica --node tcp://localhost:26657 --keyring-backend test -y --broadcast-mode block

# Query the address of the interchain account
regen query intertx ica connection-0 $WALLET_3 --home ./data/regen-ica --node tcp://localhost:26657

```