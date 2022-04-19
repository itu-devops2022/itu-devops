defmodule MinitwitElixirWeb.TimelineController do
  use MinitwitElixirWeb, :controller
  import Phoenix.Controller
  import Ecto.Query
  alias MinitwitElixir.Schemas.Message
  alias MinitwitElixir.Schemas.Follower
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo

  def index(conn, _params) do
    # If no users are logged in redirect to the public timeline
    if is_nil(get_session(conn, :user_id)) do
      redirect(conn, to: Routes.timeline_path(conn, :public_timeline))
    else
      user_id = get_session(conn, :user_id)
      user = Repo.get(User, user_id) |> Repo.preload([:followings])
      followings_id = Enum.map(user.followings, fn x -> x.id end)

      query = from(u in Message, limit: 30, where: u.author_id == ^user_id or u.author_id in ^followings_id, order_by: [desc: u.inserted_at])
      messages = Repo.all(query) |> Repo.preload([:author])
      MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :my_timeline, :success])
      render(conn, "timeline.html", messages: messages, page_title: "My Timeline", timeline_type: :timeline)
    end
  end

  def public_timeline(conn, _params) do
    query = from(u in Message, limit: 30, order_by: [desc: u.inserted_at])
    messages = Repo.all(query) |> Repo.preload([:author])

    MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :public_timeline, :success])
    #:telemetry.execute(, %{})
    render(conn, "timeline.html", messages: messages, page_title: "Public Timeline", timeline_type: :public_timeline)
  end

  def user_timeline(conn, %{"username" => username}) do

    query = from(u in Message, limit: 30, join: a in assoc(u, :author), where: a.username == ^username, order_by: [desc: u.inserted_at])
    messages = Repo.all(query) |> Repo.preload([:author])

    username_query = from(u in User, where: u.username == ^username, select: u.id)

    user_ids = Repo.all(username_query)
    if Enum.count(user_ids) == 1 do
      username_id = Enum.at(user_ids, 0)
      MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :user_timeline, :success])
      render(conn, "timeline.html", messages: messages, page_title: "#{username}'s Timeline", timeline_type: :user_timeline, currently_viewing_id: username_id)
    else
      conn
      |> put_status(404)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"404")
    end

  end

  def add_message(conn, params) do
    message = params["text"]
    user_id = get_session(conn, :user_id)
    Message.changeset(%Message{}, %{text: message, author_id: user_id}) |> Repo.insert()
    MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :tweet, :success])
    redirect(conn, to: Routes.timeline_path(conn, :index))
  end

  def follow_user(conn, %{"username" => username}) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :post_followers, :user_dont_exist])
      conn
      |> put_status(401)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"401")
    else
      other_name = username
      other_id = User.get_userid_from_username(other_name)

      if other_id == -1 do
        MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :post_followers, :follow, :other_dont_exist])
        conn
        |> put_status(404)
        |> put_view(MinitwitElixirWeb.ErrorView)
        |> render(:"404")
      else
        Follower.follow(user_id, other_id)
        MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :post_followers, :follow, :success])
        conn |>
          put_flash(:info, "You are now following #{other_name}") |>
          redirect(to: Routes.timeline_path(conn, :user_timeline, username))
      end
    end
  end

  def unfollow_user(conn, %{"username" => username}) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :post_followers, :user_dont_exist])
      conn
      |> put_status(401)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"401")
    else
      other_name = username

      other_id = User.get_userid_from_username(other_name)

      if other_id == -1 do
        MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :post_followers, :unfollow, :other_dont_exist])

        conn
        |> put_status(404)
        |> put_view(MinitwitElixirWeb.ErrorView)
        |> render(:"404")
      else
        Follower.unfollow(user_id, other_id)
        MinitwitElixir.Schemas.Metrics.increment([:minitwit_elixir, :post_followers, :unfollow, :success])
        conn |>
          put_flash(:info, "You are no longer following #{other_name}") |>
          redirect(to: Routes.timeline_path(conn, :user_timeline, username))
      end
    end
  end
end