#!/bin/bash

while ! pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - Testing if Postgres is there"
  sleep 2
done

echo "Migrating"
mix ecto.setup
echo "Migrating finished"

echo "Starting tests..."
exec mix test