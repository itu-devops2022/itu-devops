defmodule MinitwitElixir.Schemas.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    belongs_to :author, MinitwitElixir.Schemas.User
    field :text, :string
    field :flagged, :boolean


    timestamps()
  end

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, [:author_id, :text])
    |> validate_required([:author_id, :text])
  end
end
