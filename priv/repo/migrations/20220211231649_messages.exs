defmodule MinitwitElixir.Repo.Migrations.Messages do
  use Ecto.Migration

  def change do
    sql_statement = String.split(File.read!("priv/repo/migrations/initial_messages/messages.sql"), "\n")
    Enum.each(sql_statement, fn x -> execute x end)

    # Move the id counter to the number of messages + 1
    execute "SELECT setval('messages_id_seq', COALESCE((SELECT MAX(id)+1 FROM messages), 1), false);"
  end

  def down do
    IO.puts("You should manually remove all messages for now")
  end
end
