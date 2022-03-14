#!/bin/bash

while ! pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - Testing if Postgres is there"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z $(psql -Atqc "\\list $PGDATABASE") ]]; then
  echo "Database $PGDATABASE does not exist. Waiting..."

  while [[ -z $(psql -Atqc "\\list $PGDATABASE") ]] ]]
  do
  done

  echo "Database $PGDATABASE created."
fi

echo "Migrating"
mix ecto.setup
mix ecto.migrate
echo "Migrating finished"

echo "Starting tests..."
exec mix test