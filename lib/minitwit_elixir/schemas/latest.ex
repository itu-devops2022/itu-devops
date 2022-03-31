defmodule MinitwitElixir.Schemas.Latest do
  use Ecto.Schema
  alias MinitwitElixir.Repo
  alias MinitwitElixir.Schemas.User
  import Ecto.Changeset
  import Ecto.Query

  schema "latest" do
    field :number, :integer
  end

end
