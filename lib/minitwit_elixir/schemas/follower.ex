defmodule MinitwitElixir.Schemas.Follower do
  use Ecto.Schema
  alias MinitwitElixir.Schemas.Follower
  alias MinitwitElixir.Repo
  import Ecto.Query
  import Ecto.Changeset

  schema "followers" do
    belongs_to(:who, MinitwitElixir.Schemas.User)
    belongs_to(:whom, MinitwitElixir.Schemas.User)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:who_id, :whom_id])
    |> Ecto.Changeset.validate_required([:who_id, :whom_id])
  end

  # the user will follow other
  def follow(user_id, other_id) do
    Follower.changeset(%Follower{}, %{who_id: user_id, whom_id: other_id}) |>
      Repo.insert()
  end

  # the user will unfollow other
  def unfollow(user_id, other_id) do
    Repo.delete_all(from(f in Follower, where: f.who_id == ^user_id and f.whom_id == ^other_id))
  end
end
