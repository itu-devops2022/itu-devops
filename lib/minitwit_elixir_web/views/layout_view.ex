defmodule MinitwitElixirWeb.LayoutView do
  use MinitwitElixirWeb, :view
  import Plug.Conn

  alias MinitwitElixir.Repo
  alias MinitwitElixir.Schemas.User


  def get_username(user_id) do
    Repo.get(User, user_id).username
  end

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
