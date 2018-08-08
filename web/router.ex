defmodule HelpCenter.Router do
  use HelpCenter.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    #plug HelpCenter.API.Plugs.UserAuth
  end
  
  scope "/api", HelpCenter do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      post "/register",  UserController, :register
      post "/login",  UserController, :login
      get "/check", UserController, :checkjwt
      # post "/showuser", UserController, :showuser
      get "/showuser", UserController, :showuser  
      #get "/registerfb", UserController, :register_by_account_facebook
      post "/registerfb", UserController, :register_by_account_facebook
      post "/question", UserController, :create_question
    end
  end
  
end
