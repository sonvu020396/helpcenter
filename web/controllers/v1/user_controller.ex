defmodule HelpCenter.V1.UserController do
  # plug HelpCenter.API.Plugs.UserAuth when action not in [:login]
  use HelpCenter.Web, :controller
  alias HelpCenter.{Repo, User, Tools}

  # def login(conn, params) do
  # end

  def register(conn, params) do   #ham dang ky 
    email = params["email"]  #khai bao 2 bien email & password
    password = params["password"]

    cond do
      !Toools.is_empty(email) || !Toools.is_empty(password) -> Tools.json_error(conn, "message")  #check empty email, pass
      !Tools.is_email(email) -> Tools.json_error(conn, "message")  #check email dung dinh dang
      Repo.get_by!(User, email: email) -> Tools.json_error(conn, "message") #check ton tai email
      true ->
        password_has = password #encode
        
        %User{
          email: email,
          password: password_has
        }
        |> Repo.insert
        |> case do
          {:ok, _} ->
            json conn, %{success: true, message: "Register success."}
          _ ->
            Tools.json_error(conn, "message")
        end
    end
  end
 #def check valide pass
end
