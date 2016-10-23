defmodule Bleacherbot.Router do
  use Bleacherbot.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bleacherbot do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/scores", ScoreController, except: [:new, :edit]
    resources "/tags", TagController, except: [:new, :edit]
    resources "/tracks", TrackController, except: [:new, :edit]
    resources "/pushnotifications", PushNotificationController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bleacherbot do
  #   pipe_through :api
  #   end
end
