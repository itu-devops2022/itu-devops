defmodule MinitwitElixirWeb.Api.RegisterController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo
  import Ecto.Query
  import MinitwitElixirWeb.RegisterController, only: [user_can_be_registered: 1]

  def register(conn, params) do
    IO.inspect(params)
    user = %{
      "email" => params["email"],
      "pw_1" => params["pwd"],
      "pw_2" => params["pwd"],
      "username" => params["username"]
    }

    case user_can_be_registered(user) do
      :no_username ->
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a username"})
      :email_not_valid ->
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a valid email address"})
      :password_missing ->
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a password"})
      :passwords_dont_match ->
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a password"})
      :username_taken ->
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "The username is already taken"})
      :ok -> ""
    end

    User.new_user(user)

    conn |>
      put_status(204) |>
      text("")

  end

end
