defmodule MinitwitElixirWeb.Api.RegisterController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller
  alias MinitwitElixir.Schemas.User
  alias MinitwitElixir.Repo
  import Ecto.Query
  import MinitwitElixirWeb.RegisterController, only: [user_can_be_registered: 1]

  def register(conn, params) do
    MinitwitElixirWeb.Api.TimelineController.update_latest(params)

    # TODO: Do you not need to be authorized here?

    user = %{
      "email" => params["email"],
      "pw_1" => params["pwd"],
      "pw_2" => params["pwd"],
      "username" => params["username"]
    }

    case user_can_be_registered(user) do
      :no_username ->
        :telemetry.execute([:minitwit_elixir, :register, :username_missing], %{})
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a username"})
      :email_not_valid ->
        :telemetry.execute([:minitwit_elixir, :register, :email_not_valid], %{})
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a valid email address"})
      :password_missing ->
        :telemetry.execute([:minitwit_elixir, :register, :password_missing], %{})
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a password"})
      :passwords_dont_match ->
        :telemetry.execute([:minitwit_elixir, :register, :passwords_dont_match], %{})
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "You have to enter a password"})
      :username_taken ->
        :telemetry.execute([:minitwit_elixir, :register, :username_taken], %{})
        conn |>
          put_status(400) |>
          json(%{status: 400, error_msg: "The username is already taken"})
      :ok ->
        :telemetry.execute([:minitwit_elixir, :register, :success], %{})
        User.new_user(user)
        conn |>
          put_status(204) |>
          text("")
    end
  end
end
