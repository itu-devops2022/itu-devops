defmodule MinitwitElixirWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :minitwit_elixir

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_minitwit_elixir_key",
    signing_salt: "de65XtIu"
  ]

  socket "/live",
         Phoenix.LiveView.Socket,
         websocket: [
           connect_info: [
             session: @session_options
           ]
         ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
       at: "/",
       from: :minitwit_elixir,
       gzip: false,
       only: ~w(assets fonts images favicon.ico robots.txt)

         # Code reloading can be explicitly enabled under the
         # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :minitwit_elixir
  end

  plug Phoenix.LiveDashboard.RequestLogger,
       param_key: "request_logger",
       cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
       parsers: [:urlencoded, :multipart, :json],
       pass: ["*/*"],
       json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  # plug :introspect
  plug :api_routing
  plug MinitwitElixirWeb.Router

  def api_routing(conn, _opts) do
    # Get the request header
    req_header = get_req_header(conn, "accept")
    req_agent = get_req_header(conn, "user-agent")

    # Check if the request accepts JSON as a response
    accepts_json = if length(req_header) > 0 do
      Enum.at(req_header, 0) =~ "application/json"
      else
      false
    end

    python_agent = if length(req_agent) > 0 do
      Enum.at(req_agent, 0) =~ "python-requests"
      else
      false
    end

    # If it accepts JSON then treat it as an API call
    if ((accepts_json || python_agent) && Enum.at(conn.path_info, 0) != "api") do
      conn
      |> Map.replace!(:request_path, "/api#{conn.request_path}")
      |> Map.replace!(:path_info, ["api" | conn.path_info])
    else
      conn
    end
  end


  def introspect(conn, _opts) do
    IO.puts """
    Verb: #{inspect(conn.method)}
    Host: #{inspect(conn.host)}
    Headers: #{inspect(conn.req_headers)}
    """

    conn
  end
end