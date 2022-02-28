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
    if !get_session(conn, :user_id) do
      redirect(conn, to: Routes.timeline_path(conn, :public_timeline))
    end

    user_id = get_session(conn, :user_id)
    user = Repo.get(User, user_id) |> Repo.preload([:followings])
    followings_id = Enum.map(user.followings, fn x -> x.id end)

    query = from(u in Message, limit: 30, where: u.author_id == ^user_id or u.author_id in ^followings_id, order_by: [desc: u.inserted_at])
    messages = Repo.all(query) |> Repo.preload([:author])

    render(conn, "timeline.html", messages: messages, page_title: "My Timeline", timeline_type: :timeline)
  end

  def public_timeline(conn, _params) do
    query = from(u in Message, limit: 30, order_by: [desc: u.inserted_at])
    messages = Repo.all(query) |> Repo.preload([:author])

    render(conn, "timeline.html", messages: messages, page_title: "Public Timeline", timeline_type: :public_timeline)
  end

  def user_timeline(conn, %{"username" => username}) do

    query = from(u in Message, limit: 30, join: a in assoc(u, :author), where: a.username == ^username, order_by: [desc: u.inserted_at])
    messages = Repo.all(query) |> Repo.preload([:author])

    username_query = from(u in User, where: u.username == ^username, select: u.id)
    username_id = Enum.at(Repo.all(username_query), 0)

    render(conn, "timeline.html", messages: messages, page_title: "#{username}'s Timeline", timeline_type: :user_timeline, currently_viewing_id: username_id)
  end

  def add_message(conn, params) do
    message = params["text"]
    user_id = get_session(conn, :user_id)
    Message.changeset(%Message{}, %{text: message, author_id: user_id}) |> Repo.insert()
    redirect(conn, to: Routes.timeline_path(conn, :index))
  end

  def follow_user(conn, %{"username" => username}) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      conn
      |> put_status(401)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"401")
    end

    other_name = username

    other_id = User.get_userid_from_username(other_name)

    if length(other_id) == 0 do
      conn
      |> put_status(404)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"404")
    end

    # Follower.changeset(%Follower{}, %{who_id: user_id, whom_id: Enum.at(other_id, 0)}) |> Repo.insert()
    Follower.follow(user_id, other_id)
    conn |>
      put_flash(:info, "You are now following #{other_name}") |>
      redirect(to: Routes.timeline_path(conn, :user_timeline, username))
  end

  def unfollow_user(conn, %{"username" => username}) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      conn
      |> put_status(401)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"401")
    end

    other_name = username

    other_id = User.get_userid_from_username(other_name)

    if length(other_id) == 0 do
      conn
      |> put_status(404)
      |> put_view(MinitwitElixirWeb.ErrorView)
      |> render(:"404")
    end

    # Repo.delete_all(from(f in Follower, where: f.who_id == ^user_id and f.whom_id == ^Enum.at(other_id, 0)))
    Follower.unfollow(user_id, other_id)

    conn |>
      put_flash(:info, "You are no longer following #{other_name}") |>
      redirect(to: Routes.timeline_path(conn, :user_timeline, username))
  end
end