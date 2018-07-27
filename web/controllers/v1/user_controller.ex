defmodule HelpCenter.V1.UserController do
  # plug HelpCenter.API.Plugs.UserAuth when action not in [:login]
  use HelpCenter.Web, :controller
  # import Ecto.Query, only: [from: 2]

  alias HelpCenter.{Repo, User, Tools}

  def register(conn, params) do   #ham dang ky 
    email = params["email"]  #khai bao 2 bien email & password
    password = params["password"]

    cond do
      Tools.is_empty?(email) || Tools.is_empty?(password) -> Tools.json_error(conn, "not empty")  #check empty email, pass
      !Tools.is_valid_email(email) -> Tools.json_error(conn, "email invalidate")  #check email dung dinh dang
      Repo.get_by(User, email: email) -> Tools.json_error(conn, "email existing") #check ton tai email
      # !Tools.valid_password?(password) -> Tools.json_error(conn, "The password is too short")
      true ->
        password_has = Comeonin.Bcrypt.hashpwsalt(password) #encode
        
        %User{
          email: email,
          password: password_has
        }
        |> Repo.insert
        |> case do
          {:ok, _} ->
            json conn, %{success: true, message: "Register success."}
          _ ->
            Tools.json_error(conn, "message4")
        end
    end
  end
  #def register by email and password
  #---------------------------------------------------------------------
  def login(conn, params) do
    email = params["email"]
    password = params["password"]
    cond do
      Tools.is_empty?(email) || Tools.is_empty?(password) -> Tools.json_error(conn,"not empty")
      !Tools.is_valid_email(email) -> Tools.json_error(conn, "email invalidate")
      #!Repo.get_by(User, email: email) -> Tools.json_error(conn, "email not existing")
      true ->
        if user = Repo.get_by(User, email: email) do  #get information user by field email
          if Comeonin.Bcrypt.checkpw(password, user.password) do  #check passowrd client with password server 
            #json conn, %{success: true, message: "Login success."}
            map = %{:email => user.email, :username => user.username, :password => user.password}
            json conn,%{message: map} #json in phoenix
          else
            Tools.json_error(conn, "password not right")
          end
        else
          Tools.json_error(conn, "email not existing")
        end
    end
  end
  #def login by email and password
end
