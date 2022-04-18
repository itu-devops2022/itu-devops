defmodule MinitwitElixir.Repo.Migrations.Metrics do
  use Ecto.Migration

  def down do
    drop_if_exists table ("metrics")
  end

  def atom_list_to_strings(atoms) do
    res = atoms
          |> Enum.map(fn(x) -> Atom.to_string(x) end)
          |> Enum.join("_")
          |> String.to_atom

    IO.inspect(res)
  end

  def change do
    create table ("metrics") do
      add atom_list_to_strings([:minitwit_elixir, :tweet, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :tweet, :not_authorized]), :integer
      add atom_list_to_strings([:minitwit_elixir, :tweet, :user_dont_exist]), :integer

      add atom_list_to_strings([:minitwit_elixir, :register, :username_missing]), :integer
      add atom_list_to_strings([:minitwit_elixir, :register, :email_not_valid]), :integer
      add atom_list_to_strings([:minitwit_elixir, :register, :password_missing]), :integer
      add atom_list_to_strings([:minitwit_elixir, :register, :passwords_dont_match]), :integer
      add atom_list_to_strings([:minitwit_elixir, :register, :username_taken]), :integer
      add atom_list_to_strings([:minitwit_elixir, :register, :success]), :integer

      add atom_list_to_strings([:minitwit_elixir, :public_timeline, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :public_timeline, :not_authorized]), :integer
      add atom_list_to_strings([:minitwit_elixir, :my_timeline, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :user_timeline, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :user_timeline, :not_authorized]), :integer

      add atom_list_to_strings([:minitwit_elixir, :get_followers, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :get_followers, :user_dont_exist]), :integer
      add atom_list_to_strings([:minitwit_elixir, :get_followers, :not_authorized]), :integer
      add atom_list_to_strings([:minitwit_elixir, :post_followers, :follow, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :post_followers, :follow, :other_dont_exist]), :integer
      add atom_list_to_strings([:minitwit_elixir, :post_followers, :unfollow, :success]), :integer
      add atom_list_to_strings([:minitwit_elixir, :post_followers, :unfollow, :other_dont_exist]), :integer

      add atom_list_to_strings([:minitwit_elixir, :post_followers, :action_missing]), :integer
      add atom_list_to_strings([:minitwit_elixir, :post_followers, :user_dont_exist]), :integer
      add atom_list_to_strings([:minitwit_elixir, :post_followers, :not_authorized]), :integer
      add atom_list_to_strings([:minitwit_elixir, :latest, :count]), :integer
      add atom_list_to_strings([:minitwit_elixir, :api_requests, :count]), :integer

    end

    execute "INSERT INTO \"metrics\" VALUES(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)"
  end
end
