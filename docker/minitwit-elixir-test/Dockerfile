FROM elixir:latest

# Install debian packages
RUN apt-get update && \
    apt-get install --yes build-essential inotify-tools postgresql-client

ADD . /test

# Install Phoenix packagess
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.5.1

WORKDIR /test

RUN mix deps.get

RUN chmod +x /test/test_entrypoint.sh
ENTRYPOINT ["/test/test_entrypoint.sh"]