defmodule MinitwitElixir.Repo.Migrations.Initial do
  use Ecto.Migration

  def down do
    IO.puts("You should manually delete the database for now")
  end

  def change do
    drop_if_exists table ("latest")
    drop_if_exists table ("messages")
    drop_if_exists table ("followers")
    drop_if_exists table ("users")

    create table ("users") do
      add :username, :string
      add :email, :string
      add :pw_hash, :string

      timestamps()
    end

    create table("followers") do
      add(:who_id, references(:users), null: false)
      add(:whom_id, references(:users), null: false)

      timestamps()
    end

    create table ("messages") do
      add :author_id, references (:users)
      add :text, :string
      add :flagged, :boolean

      timestamps()
    end

    create table ("latest") do
      add :number, :integer
    end

    execute "INSERT INTO \"latest\" VALUES(-1, -1)"
  end
end
