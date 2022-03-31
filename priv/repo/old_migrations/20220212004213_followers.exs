defmodule MinitwitElixir.Repo.Migrations.Followers do
  use Ecto.Migration

  def change do
    sql_statement = String.split(File.read!("priv/repo/migrations/initial_followers/followers.sql"), "\n")
    Enum.each(sql_statement, fn x -> execute x end)

    # Move the id counter to the number of followers + 1
    execute "SELECT setval('followers_id_seq', COALESCE((SELECT MAX(id)+1 FROM followers), 1), false);"
  end

  def down do
    IO.puts("You should manually remove all followers for now")
  end
end
