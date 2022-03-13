#!/bin/bash

while ! pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - Testing if Postgres is there"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z $(psql -Atqc "\\list $PGDATABASE") ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
  mix deps.get
  mix ecto.create
  mix ecto.migrate
  echo "Database $PGDATABASE created."
fi

exec mix phx.server
