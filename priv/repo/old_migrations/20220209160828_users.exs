defmodule MinitwitElixir.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    sql_statement = String.split(File.read!("priv/repo/migrations/initial_users/users.sql"), "\n")
    Enum.each(sql_statement, fn x -> execute x end)

    # Move the id counter to the number of users + 1
    execute "SELECT setval('users_id_seq', COALESCE((SELECT MAX(id)+1 FROM users), 1), false);"
  end

  def down do
    IO.puts("You should manually remove all users for now")
  end
end
