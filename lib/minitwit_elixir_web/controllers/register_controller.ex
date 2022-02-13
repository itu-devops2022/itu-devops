defmodule MinitwitElixirWeb.RegisterController do
  use MinitwitElixirWeb, :controller
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo
  import Ecto.Query

  def index(conn, params) do

    # If the user was already logged in
    if get_session(conn, :user_id) do
      IO.puts("The user was already logged in")
      redirect(conn, to: Routes.page_path(conn, :index))
    end

    if params["user"] do
      user = params["user"]

      IO.inspect(user)
      IO.inspect(user["username"])

      if String.trim(user["username"]) == "" do
        put_flash(conn, :error, "You have to enter a username") |>
          redirect(to: Routes.register_path(conn, :index))
      end

      if String.trim(user["email"]) == "" or !String.contains?(user["email"], "@") do
        put_flash(conn, :error, "You have to enter a valid email address") |>
          redirect(to: Routes.register_path(conn, :index))
      end

      if String.trim(user["pw_1"]) == "" do
        put_flash(conn, :error, "You have to enter a password") |>
          redirect(to: Routes.register_path(conn, :index))
      end

      if user["pw_1"] != user["pw_2"] do
        put_flash(conn, :error, "The two passwords do not match") |>
          redirect(to: Routes.register_path(conn, :index))
      end

      if length(Repo.all(from(i in User, where: i.username == ^user["username"], limit: 1))) == 1 do
        put_flash(conn, :error, "The username is already taken") |>
          redirect(to: Routes.register_path(conn, :index))
      end


      pw_hash = User.put_password_hash(user["pw_1"])

      User.changeset(%User{}, %{username: user["username"], email: user["email"], pw_hash: pw_hash}) |> Repo.insert()

      conn |>
        put_flash(:info, "You were successfully registered and can login now") |>
        redirect(to: Routes.login_path(conn, :index))

    end

    changeset = User.changeset(%User{})
    render(conn, "register.html", changeset: changeset, page_title: "Sign up")
  end

end
