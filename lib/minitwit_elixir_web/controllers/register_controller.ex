defmodule MinitwitElixirWeb.RegisterController do
  use MinitwitElixirWeb, :controller
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo
  import Ecto.Query

  def index(conn, params) do

    # If the user was already logged in
    if get_session(conn, :user_id) do
      IO.puts("The user was already logged in")
      redirect(conn, to: Routes.timeline_path(conn, :index))
    end

    if params["user"] do
      user = params["user"]

      IO.inspect(user)
      IO.inspect(user["username"])

      case user_can_be_registered(user) do
        :no_username ->
          put_flash(conn, :error, "You have to enter a username") |>
            redirect(to: Routes.register_path(conn, :index))
        :email_not_valid ->
          put_flash(conn, :error, "You have to enter a valid email address") |>
            redirect(to: Routes.register_path(conn, :index))
        :password_missing ->
          put_flash(conn, :error, "You have to enter a password") |>
            redirect(to: Routes.register_path(conn, :index))
        :passwords_dont_match ->
          put_flash(conn, :error, "The two passwords do not match") |>
            redirect(to: Routes.register_path(conn, :index))
        :username_taken ->
          put_flash(conn, :error, "The username is already taken") |>
            redirect(to: Routes.register_path(conn, :index))
        :ok -> ""
      end

      User.new_user(user)

      conn |>
        put_flash(:info, "You were successfully registered and can login now") |>
        redirect(to: Routes.login_path(conn, :index))

    end

    changeset = User.changeset(%User{})
    render(conn, "register.html", changeset: changeset, page_title: "Sign up")
  end


  def user_can_be_registered(user)  do
    IO.inspect(user)
    cond do
      String.trim(user["username"]) == "" -> :no_username
      String.trim(user["email"]) == "" or !String.contains?(user["email"], "@") -> :email_not_valid
      String.trim(user["pw_1"]) == "" -> :password_missing
      user["pw_1"] != user["pw_2"] -> :passwords_dont_match
      length(Repo.all(from(i in User, where: i.username == ^user["username"], limit: 1))) == 1  -> :username_taken
      true -> :ok
    end
  end
end