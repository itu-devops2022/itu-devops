defmodule MinitwitElixir.Schemas.User do
  use Ecto.Schema
  alias MinitwitElixir.Repo
  alias MinitwitElixir.Schemas.User
  import Ecto.Changeset
  import Ecto.Query

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
    hash = Pbkdf2.hash_pwd_salt("Hello", rounds: 50000)
    hash
  end

  def new_user(user) do
    pw_hash = put_password_hash(user["pw_1"])
    changeset(%User{}, %{username: user["username"], email: user["email"], pw_hash: pw_hash})
    |> Repo.insert()
  end

  # Returns user_id if username exists, returns -1 otherwise
  def get_userid_from_username(username) do
    username_query = from(u in User, where: u.username == ^username, select: u.id)
    Enum.at(Repo.all(username_query), 0, -1)
  end

  def get_followings_from_username(user_id, followings_count) do
    user = Repo.get(User, user_id) |> Repo.preload([:followings])
    user.followings
  end
end
