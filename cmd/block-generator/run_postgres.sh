#!/usr/bin/env bash

# This script is useful if you want to launch the runner
# in a debugger. Simply start this script and run with:
# ./block-generator runner \
#       -d 5s \
#       -i ./../algorand-indexer/algorand-indexer \
#       -c "host=localhost user=algorand password=algorand dbname=algorand port=15432 sslmode=disable" \
#       -r results \
#       -s scenarios/config.payment.small.yml

set -e

POSTGRES_CONTAINER=generator-test-container
POSTGRES_PORT=15432
POSTGRES_DATABASE=generator_db
CONFIG=${1:-"$(dirname $0)/test_config.yml"}
echo "Using config file: $CONFIG"

function start_postgres() {
  docker rm -f $POSTGRES_CONTAINER > /dev/null 2>&1 || true

  # Start postgres container...
  docker run \
     -d \
     --name $POSTGRES_CONTAINER \
     -e POSTGRES_USER=algorand \
     -e POSTGRES_PASSWORD=algorand \
     -e PGPASSWORD=algorand \
     -p $POSTGRES_PORT:5432 \
     postgres

   sleep 5

  docker exec -it $POSTGRES_CONTAINER psql -Ualgorand -c "create database $POSTGRES_DATABASE"
}

function shutdown() {
  docker rm -f $POSTGRES_CONTAINER > /dev/null 2>&1 || true
}

trap shutdown EXIT

pushd $(dirname "$0") > /dev/null
echo "Starting postgres container at: \n\t\"host=localhost user=algorand password=algorand dbname=algorand port=15432\""
start_postgres
echo "Sleeping, use Ctrl-C to end test."
sleep 1000000000000000

