defmodule MinitwitElixirWeb.Api.TimelineController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller
  alias MinitwitElixir.Schemas.Message
  alias MinitwitElixir.Schemas.Follower
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo
  import Ecto.Query

  def latest(conn, _params) do
    json(conn, %{latest: conn.assigns[:latest] || -1})
  end

  def update_latest(conn, _params) do
    conn |>
      assign(:user_id, 5) |>
      text("")
  end

  def all_msgs(conn, params) do
    # update latest missing

    not_req_from_simulator(conn)

    no_msgs = params["no"] || 100

    query = from(u in Message, limit: ^no_msgs, where: u.flagged == false, order_by: [desc: u.inserted_at])
    messages = Repo.all(query) |> Repo.preload([:author])

    res = Enum.map(messages, fn x ->  %{content: x.text, pub_date: x.inserted_at, user: x.author.username} end)
    json(conn, res)
  end

  def get_user_msgs(conn, %{"username" => username} = params) do
    # Update latest missing

    not_req_from_simulator(conn)

    no_msgs = params["no"] || 100
    user_id = verify_user_exists(conn, username)

    # query = from(u in Message, limit: ^no_msgs, where: u.author_id == ^user_id, order_by: [desc: u.inserted_at])
    # messages = Repo.all(query) |> Repo.preload([:author])
    messages = Message.get_messages_by_author_id(user_id, no_msgs)

    res = Enum.map(messages, fn x ->  %{content: x.text, pub_date: x.inserted_at, user: x.author.username} end)
    json(conn, res)
  end

  def post_user_msgs(conn, %{"username" => username} = params) do

    not_req_from_simulator(conn)

    user_id = verify_user_exists(conn, username)

    message = params["content"]

    Message.insert_message(message, user_id)

    conn |>
      put_status(204) |>
      text("")
  end

  def get_followers(conn, %{"username" => username} = params) do
    not_req_from_simulator(conn)

    no_followers = params["no"] || 100

    user_id = verify_user_exists(conn, username)

    followings = User.get_followings_from_username(user_id, no_followers)
    usernames = Enum.take(Enum.map(followings, fn x ->  x.username end), no_followers)
    conn |>
      json(%{follows: usernames})

  end

  def post_followers(conn, %{"username" => username} = params) do
    not_req_from_simulator(conn)

    user_id = verify_user_exists(conn, username)

    case params do
      %{"follow" => other_name} ->
        other_id = verify_user_exists(conn, other_name)
        Follower.follow(user_id, other_id)
        conn |>
          put_status(204) |>
          text("")
      %{"unfollow" =>  other_name} ->
        other_id = verify_user_exists(conn, other_name)
        Follower.unfollow(user_id, other_id)
        conn |>
          put_status(204) |>
          text("")
      %{} -> conn |> put_status(404) |> text("Hej")
    end

  end

  def verify_user_exists(conn, username) do
    user_id = User.get_userid_from_username(username)
    if user_id == -1 do
      conn |>
        put_status(404) |>
        text("")
    end
    user_id
  end

  def not_req_from_simulator(conn) do
    auth = get_req_header(conn, "authorization")
    if Enum.at(auth, 0) != "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh" do
      err = "You are not authorized to use this resource!"
      conn |>
        put_status(403) |>
        json(%{status: 403, error_msg: err})
    end

  end
end
