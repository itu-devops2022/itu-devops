#!/bin/bash

while ! pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - Testing if Postgres is there"
  sleep 2
done

echo "Get deps"
mix deps.get

echo "Migrating"
mix ecto.setup
echo "Migrating finished"

echo "Starting tests..."
exec mix test

if [[ $? != 0 ]]; then
  echo "exit code for test: " $?
  exit $?
fi
