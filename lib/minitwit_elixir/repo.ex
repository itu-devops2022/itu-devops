defmodule MinitwitElixir.Repo do
  use Ecto.Repo,
    otp_app: :minitwit_elixir,
    adapter: Ecto.Adapters.Postgres
end
