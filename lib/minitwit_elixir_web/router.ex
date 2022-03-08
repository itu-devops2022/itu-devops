defmodule MinitwitElixirWeb.Router do
  use MinitwitElixirWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MinitwitElixirWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :docker, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MinitwitElixirWeb.Telemetry
    end
  end

  scope "/", MinitwitElixirWeb do
    pipe_through :browser

    get "/", TimelineController, :index
    get "/public", TimelineController, :public_timeline
    get "/register", RegisterController, :index
    post "/register", RegisterController, :index
    get "/login", LoginController, :index
    post "/login", LoginController, :index
    get "/logout", LoginController, :logout
    post "/add_message", TimelineController, :add_message
    get "/:username",
        TimelineController,
        :user_timeline # Captures the person as an argument and passes it to the page-controllers show function
    get "/:username/follow", TimelineController, :follow_user
    get "/:username/unfollow", TimelineController, :unfollow_user
  end

  # Other scopes may use custom stacks.
  scope "/api", MinitwitElixirWeb do
    pipe_through :api

    get "/latest", Api.TimelineController, :latest
    #get "/updateLatest", Api.TimelineController, :update_latest
    post "/register", Api.RegisterController, :register
    get "/msgs", Api.TimelineController, :all_msgs
    get "/msgs/:username", Api.TimelineController, :get_user_msgs
    post "/msgs/:username", Api.TimelineController, :post_user_msgs
    get "/fllws/:username", Api.TimelineController, :get_followers
    post "/fllws/:username", Api.TimelineController, :post_followers

  end

  

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
