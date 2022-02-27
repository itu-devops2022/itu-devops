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

CMD ["/app/entrypoint.sh"]
