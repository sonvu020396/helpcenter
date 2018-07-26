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
      # !Tools.is_email(email) -> Tools.json_error(conn, "message")  #check email dung dinh dang
      Repo.check_validate_email!(email) -> json conn, %{success: true, message: "email valide"}
      Repo.check_validate_pass!(password) -> json conn, %{success: true, message: "password valide"}
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
  # def register

  def check_validate_email(conn, params) do
    if not Validator.is_email?(params["email"]) do
      Tools.json_error(conn, " email invalide ")
    end
  end
 #def check valide email

  def check_validate_pass(conn, params) do
    if not Validator.min_length?(params["password"], 6) do
      Tools.json_error(conn, "password must be 6 or more characters")
    end
  end
 #def check valide pass
end
