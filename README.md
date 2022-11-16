# Interchain Accounts Testing

## Setup

1. Clone Akash repository and build the application binary

```bash

git clone https://github.com/aleem1314/akash.git
cd akash
git checkout aleem/bump-ibc

make install
```

2. Clone Regen repository and build the application binary

```bash
git clone https://github.com/regen-network/regen-ledger.git
cd regen-ledger
git checkout aleem/ica-fixes

make install
```

3. Download and install an Hermes relayer.

```bash
cargo install --version 0.15.0 ibc-relayer-cli --bin hermes --locked
```

4. Bootstrap both chains, configure the relayer and create an IBC connection (on top of clients that are created as well)
```bash
make init-hermes
```

5. Start the relayer
```bash
make start-hermes
```

## Demo

**NOTE:** For the purposes of this demo the setup scripts have been provided with a set of hardcoded mnemonics that generate deterministic wallet addresses used below.

```bash
# Store the following account addresses within the current shell env
export WALLET_1=$(akash keys show wallet1 -a --keyring-backend test --home ./data/akash-ica) && echo $WALLET_1;
export WALLET_2=$(akash keys show wallet2 -a --keyring-backend test --home ./data/akash-ica) && echo $WALLET_2;
export WALLET_3=$(regen keys show wallet3 -a --keyring-backend test --home ./data/regen-ica) && echo $WALLET_3;
export WALLET_4=$(regen keys show wallet4 -a --keyring-backend test --home ./data/regen-ica) && echo $WALLET_1;
```

### Registering an Interchain Account via IBC

Register an Interchain Account using the `icaauth register` cmd. 
Here the message signer is used as the account owner.

```bash
# Register an interchain account on behalf of WALLET_1 where chain akash-ica is the interchain accounts host
akash tx icaauth register --from=$WALLET_1 --connection-id connection-0 --chain-id akash-ica --home ./data/akash-ica --node tcp://localhost:26656 --keyring-backend test -y --broadcast-mode block

# Query the address of the interchain account
akash query icaauth icaccounts connection-0 $WALLET_1 --home ./data/akash-ica --node tcp://localhost:26656

export ICA_ADDR=$(akash query icaauth icaccounts connection-0 $WALLET_1 --home ./data/akash-ica --node tcp://localhost:26656 -o json | jq -r '.interchain_account_address') && echo $ICA_ADDR

```

### Funding the Interchain Account wallet

```bash
# Query the interchain account balance on the host chain. It should be empty.
regen q bank balances $ICA_ADDR --chain-id regen-ica --node tcp://localhost:26657

# Send funds to the interchain account.
regen tx bank send $WALLET_3 $ICA_ADDR 100000uregen --chain-id regen-ica --home ./data/regen-ica --node tcp://localhost:26657 --keyring-backend test -y

# Query the balance once again and observe the changes
regen q bank balances $ICA_ADDR --chain-id regen-ica --node tcp://localhost:26657
```

### Sending Interchain Account transactions

```bash
# Output the host chain validator operator address: regenvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnah3mns
cat ./data/regen-ica/config/genesis.json | jq -r '.app_state.genutil.gen_txs[0].body.messages[0].validator_address'

# create delegate tx
echo '
{
    "@type":"/cosmos.staking.v1beta1.MsgDelegate",
    "delegator_address":"<add-your-ica-account-address-here>",
    "validator_address":"regenvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnah3mns",
    "amount": {
        "denom": "uregen",
        "amount": "1234"
    }
}' > delegate.json

# Submit a staking delegation tx using the interchain account via ibc
akash tx icaauth submit delegate.json \
--connection-id connection-0 --from $WALLET_1 --chain-id akash-ica --home ./data/akash-ica --node tcp://localhost:26656 --keyring-backend test -y --broadcast-mode block


# Wait until the relayer has relayed the packet

# Inspect the staking delegations on the host chain
regen q staking delegations-to regenvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnah3mns --home data/regen-ica --node tcp://127.0.0.1:26657
```

Example 2: Bank Send

```bash
# Submit a bank send tx using the interchain account via ibc

echo '{
    "@type":"/cosmos.bank.v1beta1.MsgSend",
    "from_address":"<add-your-ica-account-address-here>",
    "to_address":"regen1d84j42rnfgq60sjxpzj4pgfu35mew34d7r65en",
    "amount": [
        {
            "denom": "uregen",
            "amount": "1000"
        }
    ]
}' > send.json

akash tx icaauth submit send.json --connection-id connection-0 --from $WALLET_1 --chain-id akash-ica --home ./data/akash-ica --node tcp://localhost:26656 --keyring-backend test -y

# Wait until the relayer has relayed the packet

# Query the interchain account balance on the host chain
regen q bank balances $ICA_ADDR --chain-id regen-ica --node tcp://localhost:26657
```

Example 3: Testing not allowed message

```bash
# Submit a withdraw all rewards tx using the interchain account via ibc

echo '{
    "@type":"/cosmos.staking.v1beta1.MsgUndelegate",
    "delegator_address":"<add-your-ica-account-address-here>",
    "validator_address":"regenvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnah3mns",
    "amount": [
        {
            "denom": "uregen",
            "amount": "10"
        }
    ]
}' > undelegate.json

akash tx icaauth submit undelegate.json --connection-id connection-0 --from $WALLET_1 --chain-id akash-ica --home ./data/akash-ica --node tcp://localhost:26656 --keyring-backend test -y

# Wait until the relayer has relayed the packet

# Query the interchain account unbonding delegation on the host chain
# This should return no unbonding delegations.

regen q staking unbonding-delegations $ICA_ADDR --chain-id regen-ica --node tcp://localhost:26657
```
