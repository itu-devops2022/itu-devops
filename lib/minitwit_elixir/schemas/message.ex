defmodule MinitwitElixir.Schemas.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias MinitwitElixir.Repo
  alias MinitwitElixir.Schemas.Message
  import Ecto.Query

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

  def get_messages_by_author_id(author_id, message_count) do
    query = from(u in Message, limit: ^message_count, where: u.author_id == ^author_id, order_by: [desc: u.inserted_at])
    Repo.all(query) |> Repo.preload([:author])
  end

  def insert_message(message, user_id) do
    Message.changeset(%Message{}, %{text: message, author_id: user_id}) |> Repo.insert()
  end

end
