defmodule MinitwitElixir.Schemas.Follower do
  use Ecto.Schema

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
end
