defmodule MinitwitElixirWeb.LoginController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo
  import Ecto.Query

  def index(conn, params) do

    # If the user was already logged in
    if get_session(conn, :user_id) do
      IO.puts("A user is already logged in")
      redirect(conn, to: Routes.timeline_path(conn, :index))
    end

    if params["user"] do
      user = params["user"]
      query = from(i in User, where: i.username == ^user["username"])
      db_user = Repo.one(query)

      if db_user && Pbkdf2.verify_pass(user["password"], db_user.pw_hash) do

        put_session(conn, :user_id, db_user.id) |>
          put_flash(:info, "You were logged in") |>
          redirect(to: Routes.timeline_path(conn, :index))
      else
        put_flash(conn, :error, "Invalid username or password") |>
          render("login.html", page_title: "Sign in")
      end
    else
      render(conn, "login.html", page_title: "Sign in")
    end
  end

  def logout(conn, _params) do
    delete_session(conn, :user_id) |>
      put_flash(:info, "You were logged out") |>
      redirect(to: Routes.timeline_path(conn, :public_timeline))
  end

end
