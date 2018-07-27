defmodule HelpCenter.Router do
  use HelpCenter.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HelpCenter do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      post "/register",  UserController, :register
      post "/login",  UserController, :login
    end
  end
end
