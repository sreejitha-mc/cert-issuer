#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# start the bitcoin service
bitcoind -regtest -daemon

# wait for bitcoind to start accepting connections
while ! nc -z localhost 8332 </dev/null; do sleep 10; done

# Create an issuing address and save the output
ISSUER=$(bitcoin-cli -regtest getnewaddress "" legacy)
sed -i.bak "s/<issuing-address>/$ISSUER/g" /etc/cert-issuer/conf.ini
KEY="$(bitcoin-cli -regtest dumpprivkey $ISSUER)"
echo $KEY > /etc/cert-issuer/pk_issuer.txt

# advance network
bitcoin-cli -regtest generatetoaddress 101 $ISSUER

# send btc to issuer address
bitcoin-cli -regtest sendtoaddress $ISSUER 5

# start web service
service nginx start && uwsgi --ini wsgi.ini
