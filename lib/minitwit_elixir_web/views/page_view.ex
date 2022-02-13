defmodule MinitwitElixirWeb.PageView do
  use MinitwitElixirWeb, :view
  import Plug.Conn
  alias MinitwitElixir.Repo
  alias MinitwitElixir.Schemas.User

  def is_following(conn, other_id) do
    user = Repo.get(User, get_session(conn, :user_id)) |> Repo.preload([:followings])
    Enum.member?(Enum.map(user.followings, fn x -> x.id end), other_id)
  end

end
