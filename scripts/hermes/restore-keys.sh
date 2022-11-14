#!/bin/bash
set -e

# Load shell variables
. ./scripts/hermes/variables.sh

### Sleep is needed otherwise the relayer crashes when trying to init
sleep 1
### Restore Keys
$HERMES_BINARY -c ./scripts/hermes/config.toml keys restore akash-ica -m "alley afraid soup fall idea toss can goose become valve initial strong forward bright dish figure check leopard decide warfare hub unusual join cart"
sleep 5

$HERMES_BINARY -c ./scripts/hermes/config.toml keys restore regen-ica -m "record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"
sleep 5