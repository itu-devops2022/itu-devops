defmodule MinitwitElixir.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :pw_hash, :string
    many_to_many :followers, MinitwitElixir.Schemas.User, join_through: MinitwitElixir.Schemas.Follower, join_keys: [whom_id: :id, who_id: :id]
    many_to_many :followings, MinitwitElixir.Schemas.User, join_through: MinitwitElixir.Schemas.Follower, join_keys: [who_id: :id, whom_id: :id]

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email, :pw_hash])
    |> validate_required([:username, :email, :pw_hash])
  end

  def put_password_hash(pw) do
    Pbkdf2.hash_pwd_salt(pw)
  end

end
