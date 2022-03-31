defmodule MinitwitElixirWeb.Api.TimelineController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller
  alias MinitwitElixir.Schemas.Message
  alias MinitwitElixir.Schemas.Follower
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Schemas.Latest
  alias MinitwitElixir.Repo
  import Ecto.Query

  def latest(conn, _params) do
    latest = Repo.get(Latest, -1).number
    :telemetry.execute([:minitwit_elixir, :latest, :count], %{})
    json(conn, %{latest: latest})
  end

  def update_latest(params) do
    if !is_nil(params["latest"]) do
      parsed = Integer.parse(params["latest"])
      new_latest = if tuple_size(parsed) == 2 do
        elem(parsed, 0)
      else
        -1
      end

      latest = Repo.get(Latest, -1)
      latest = Ecto.Changeset.change latest, number: new_latest
      Repo.update(latest)
    end
  end

  def all_msgs(conn, params) do
    update_latest(params)

    if simulator_authorized(conn) do
      no_msgs = params["no"] || 100

      query = from(u in Message, limit: ^no_msgs, order_by: [desc: u.inserted_at])
      messages = Repo.all(query) |> Repo.preload([:author])

      res = Enum.map(messages, fn x ->  %{content: x.text, pub_date: x.inserted_at, user: x.author.username} end)
      :telemetry.execute([:minitwit_elixir, :public_timeline, :success], %{})
      json(conn, res)
    else
      :telemetry.execute([:minitwit_elixir, :public_timeline, :not_authorized], %{})
      not_authorized_response(conn)
    end
  end

  def get_user_msgs(conn, %{"username" => username} = params) do
    # Update latest missing
    update_latest(params)

    if simulator_authorized(conn) do
      no_msgs = elem(Integer.parse(params["no"]), 0) || 100
      user_id = User.get_userid_from_username(username)

      # query = from(u in Message, limit: ^no_msgs, where: u.author_id == ^user_id, order_by: [desc: u.inserted_at])
      # messages = Repo.all(query) |> Repo.preload([:author])
      messages = Message.get_messages_by_author_id(user_id, no_msgs)

      res = Enum.map(messages, fn x ->  %{content: x.text, pub_date: x.inserted_at, user: x.author.username} end)
      :telemetry.execute([:minitwit_elixir, :user_timeline, :success], %{})
      json(conn, res)
    else
      :telemetry.execute([:minitwit_elixir, :user_timeline, :not_authorized], %{})
      not_authorized_response(conn)
    end
  end

  def post_user_msgs(conn, %{"username" => username} = params) do
    update_latest(params)

    if simulator_authorized(conn) do
        user_id = User.get_userid_from_username(username)

        if user_id != -1 do
          message = params["content"]

          inserted = Message.insert_message(message, user_id)
          :telemetry.execute([:minitwit_elixir, :tweet, :success], %{})
          conn |>
            put_status(204) |>
            text("")
        else
          :telemetry.execute([:minitwit_elixir, :tweet, :user_dont_exist], %{})
          user_not_found_response(conn, username)
        end
      else
        :telemetry.execute([:minitwit_elixir, :tweet, :not_authorized], %{})
        not_authorized_response(conn)
    end
  end

  def get_followers(conn, %{"username" => username} = params) do
    update_latest(params)

    if simulator_authorized(conn) do
      user_id = User.get_userid_from_username(username)

      if user_id != -1 do
        no_followers = elem(Integer.parse(params["no"]), 0) || 100

        followings = User.get_followings_from_username(user_id, no_followers)
        usernames = Enum.take(Enum.map(followings, fn x ->  x.username end), no_followers)
        :telemetry.execute([:minitwit_elixir, :get_followers, :success], %{})
        conn |>
          json(%{follows: usernames})
      else
        :telemetry.execute([:minitwit_elixir, :get_followers, :user_dont_exist], %{})
        user_not_found_response(conn, username)
      end
    else
      :telemetry.execute([:minitwit_elixir, :get_followers, :not_authorized], %{})
      not_authorized_response(conn)
    end
  end

  def post_followers(conn, %{"username" => username} = params) do
    update_latest(params)

    if simulator_authorized(conn) do
      user_id = User.get_userid_from_username(username)

      if user_id != -1 do
        case params do
          %{"follow" => other_name} ->
            other_id = User.get_userid_from_username(other_name)

            if other_id != -1 do
                Follower.follow(user_id, other_id)
                :telemetry.execute([:minitwit_elixir, :post_followers, :follow, :success], %{})
                conn |>
                  put_status(204) |>
                  text("")
              else
                :telemetry.execute([:minitwit_elixir, :post_followers, :follow, :other_dont_exist], %{})
                user_not_found_response(conn, other_name)
            end

          %{"unfollow" =>  other_name} ->
            other_id = User.get_userid_from_username(other_name)

            if other_id != -1 do
              Follower.unfollow(user_id, other_id)
              :telemetry.execute([:minitwit_elixir, :post_followers, :unfollow, :success], %{})
              conn |>
                put_status(204) |>
                text("")
            else
              :telemetry.execute([:minitwit_elixir, :post_followers, :unfollow, :other_dont_exist], %{})
              user_not_found_response(conn, other_name)
            end

          %{} ->
            :telemetry.execute([:minitwit_elixir, :post_followers, :action_missing], %{})
            conn |> put_status(404) |> text("")
        end
      else
        :telemetry.execute([:minitwit_elixir, :post_followers, :user_dont_exist], %{})
        user_not_found_response(conn, username)
      end
    else
      :telemetry.execute([:minitwit_elixir, :post_followers, :not_authorized], %{})
      not_authorized_response(conn)
    end

  end

  def simulator_authorized(conn) do
    auth = get_req_header(conn, "authorization")
    Enum.at(auth, 0) == "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh"
  end

  def not_authorized_response(conn) do
    err = "You are not authorized to use this resource!"
    conn |>
      put_status(403) |>
      json(%{status: 403, error_msg: err})
  end

  def user_not_found_response(conn, username) do
    IO.puts("The user id was not found for user: #{username}")
    conn |>
      put_status(404) |>
      text("")
  end
end
