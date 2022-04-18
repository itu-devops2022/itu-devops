defmodule MinitwitElixir.Schemas.Metrics do
  use Ecto.Schema
  alias MinitwitElixir.Repo
  alias MinitwitElixir.Schemas.User
  import Ecto.Changeset
  import Ecto.Query

  schema "metrics" do
    field :minitwit_elixir_tweet_success, :integer
    field :minitwit_elixir_tweet_not_authorized, :integer
    field :minitwit_elixir_tweet_user_dont_exist, :integer

    field :minitwit_elixir_register_username_missing, :integer
    field :minitwit_elixir_register_email_not_valid, :integer
    field :minitwit_elixir_register_password_missing, :integer
    field :minitwit_elixir_register_passwords_dont_match, :integer
    field :minitwit_elixir_register_username_taken, :integer
    field :minitwit_elixir_register_success, :integer

    field :minitwit_elixir_public_timeline_success, :integer
    field :minitwit_elixir_public_timeline_not_authorized, :integer
    field :minitwit_elixir_my_timeline_success, :integer
    field :minitwit_elixir_user_timeline_success, :integer
    field :minitwit_elixir_user_timeline_not_authorized, :integer

    field :minitwit_elixir_get_followers_success, :integer
    field :minitwit_elixir_get_followers_user_dont_exist, :integer
    field :minitwit_elixir_get_followers_not_authorized, :integer
    field :minitwit_elixir_post_followers_follow_success, :integer
    field :minitwit_elixir_post_followers_follow_other_dont_exist, :integer
    field :minitwit_elixir_post_followers_unfollow_success, :integer
    field :minitwit_elixir_post_followers_unfollow_other_dont_exist, :integer

    field :minitwit_elixir_post_followers_action_missing, :integer
    field :minitwit_elixir_post_followers_user_dont_exist, :integer
    field :minitwit_elixir_post_followers_not_authorized, :integer
    field :minitwit_elixir_latest_count, :integer
    field :minitwit_elixir_api_requests_count, :integer
  end

  def atom_list_to_string(atoms) do
    res = atoms
          |> Enum.map(fn(x) -> Atom.to_string(x) end)
          |> Enum.join("_")
          |> String.to_atom
  end

  def increment(val) do
    Repo.transaction(fn ->
      mets = Repo.get(MinitwitElixir.Schemas.Metrics, 0)
      Ecto.Adapters.SQL.query!(
        Repo, "UPDATE metrics SET #{atom_list_to_string(val)} = #{Map.from_struct(mets)[atom_list_to_string(val)] + 1};"
      )
    end)
  end

end