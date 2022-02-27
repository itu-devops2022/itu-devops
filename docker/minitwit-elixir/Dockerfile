FROM elixir:latest

# Install debian packages
RUN apt-get update && \
    apt-get install --yes build-essential inotify-tools postgresql-client 

ADD . /app

# Install Phoenix packages
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.5.1

WORKDIR /app

RUN mix deps.get

EXPOSE 4000

# RUN chmod +x /app/entrypoint.sh
# CMD ["/app/entrypoint.sh"]

RUN while ! pg_isready -h $PGHOST -p $PGPORT -U $PGUSER \
do \
  echo "$(date) - Testing if Postgres is there" \
  sleep 2 \
done \

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then \
  echo "Database $PGDATABASE does not exist. Creating..." \
  mix deps.get \
  mix ecto.create \
  mix ecto.migrate \
  echo "Database $PGDATABASE created." \
fi \
 
exec mix phx.server \
