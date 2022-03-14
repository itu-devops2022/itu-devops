# MinitwitElixir
![](https://app.travis-ci.com/itu-devops2022/itu-devops.svg?branch=master)
## Why Elixir and Phoenix?

"Elixir and Phoenix are fast. For example, [tests of Elixir’s performance](https://mlsdev.com/services/software-testing) show much better results during software testing services than those for Ruby, and Phoenix response times are measured in microseconds. Impressive, isn’t it? Speed matters a lot when we speak about user experience. It is great to see that the app reacts and responds quickly to all actions. Additionally, good performance helps to save energy and money." [source](https://mlsdev.com/blog/elixir-programming-facts-to-know-for-better-app-development)

## Via Docker

Install Docker and create an app image: `docker build -f docker/app/Dockerfile -t app .`
Get it up and running via Docker Compose: `docker-compose up`

If you need to use postgres, seperately you can have it by running: `docker build -f docker/db/Dockerfile -t db .`

## Manually

Follow [this instruction to install Elixir on your computer](https://elixir-lang.org/install.html).
Install Postgres and create database called `minitwit_elixir_dev` on port 5432. [Follow this instruction](https://www.postgresql.org/download/)

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup` and make sure it is migrated using `mix ecto.migrate`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
