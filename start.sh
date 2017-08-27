#!/bin/bash

ACCOUNT=$(geth --networkid 7631461 --datadir $HOME/.tenere/ethereum account | grep -Eo "Account #0: {[a-z0-9]+}" | grep -Eo "[a-z0-9]{40}")

if [ -z "$ACCOUNT" ]; then
  geth --networkid 7631461 --datadir $HOME/.tenere/ethereum init genesis.json
  geth --networkid 7631461 --datadir $HOME/.tenere/ethereum --password "/dev/null" account new
  ACCOUNT=$(geth --networkid 7631461 --datadir $HOME/.tenere/ethereum account | grep -Eo "Account #0: {[a-z0-9]+}" | grep -Eo "[a-z0-9]{40}")
fi

geth --networkid 7631461 --datadir $HOME/.tenere/ethereum --unlock "$ACCOUNT" --password "/dev/null" --rpc --rpccorsdomain "*" --mine --verbosity 1 2> >(cat) | sed -e 's/^/[geth] /' \
& sleep 1 && swarm --datadir $HOME/.tenere/ethereum --bzzaccount "$ACCOUNT" --ens-api='' --maxpeers 0 --corsdomain "*" <<< '' | sed -e 's/^/[swarm] /' \
& sleep 7 && nodemon app | sed -e 's/^/[node] /' \
& webpack --watch
& wait