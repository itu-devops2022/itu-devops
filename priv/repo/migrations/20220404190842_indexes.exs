defmodule MinitwitElixir.Repo.Migrations.Indexes do
  use Ecto.Migration

  def change do
    create index(:messages, [:author_id])
  end
end
