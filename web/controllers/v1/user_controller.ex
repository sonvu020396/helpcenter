defmodule HelpCenter.V1.UserController do
  use HelpCenter.Web, :controller
  plug HelpCenter.API.Plugs.UserAuth when action not in [:login, :register, :register_by_account_facebook]  # call plug in controller
  # import Ecto.Query, only: [from: 2]
  alias HelpCenter.{Repo, User, Tools}

  def register(conn, params) do   #ham dang ky 
    email = params["email"]  #khai bao 2 bien email & password
    password = params["password"]
    IO.inspect params["password"]

    cond do
      Tools.is_empty?(email) || Tools.is_empty?(password) -> Tools.json_error(conn, "not empty")  #check empty email, pass
      !Tools.is_valid_email(email) -> Tools.json_error(conn, "email invalidate")  #check email dung dinh dang
      Repo.get_by(User, email: email) -> Tools.json_error(conn, "email existing") #check ton tai email
      true ->
        password_has = Comeonin.Bcrypt.hashpwsalt(password) #encode
        
        %User{
          email: email,
          password: password_has
        }
        |> Repo.insert #note
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
            map = %{:id => user.id, :email => user.email, :username => user.username, :password => user.password}
            # xem map vs enum trong elixir rou chinh lai  
            jwt = JsonWebToken.sign(%{id: user.id, email: user.email, password: user.password, exp: 1600819380}, %{key: "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"})
            #create json web token(jwt) & #set time for jwt (exp)
            json conn,%{
              success: "Login success",
              token: jwt,
              data: map
            }
          else
            Tools.json_error(conn, "password not right")
          end
        else
          Tools.json_error(conn, "email not existing")
        end
    end
  end
  #def login by email and password
  #---------------------------------------------------------------------
 
  def checkjwt(conn, _params) do
   json conn,%{data: "hello"}
  end
  #def checkjwt
  #---------------------------------------------------------------------
  
  def showuser(conn, _params) do
    user = conn.assigns.current_user #lay thong tin user va gan vo bien user
    #C1:
    # data = %{ :id => user.id, :username => user.username, :email => user.email, :phone => user.phone, :is_active => user.is_active}
    # json conn, %{
    #   success: "Information user",
    #   data: data
    # }
    #C2: using Map
    data = Map.take(user,[:fb_id, :username, :email, :phone, :is_active])
    json conn, %{
      data: data
    }

  end
  #def show information of user
  #----------------------------------------------------------------------

  def register_by_account_facebook(conn, params) do

    url =  "https://graph.facebook.com/me?access_token=EAAAAUaZA8jlABAETAZADXv5a3TK3UJHXhrkv3XKJ3oeZAz8yzudKXJXnbZBZBuP0D8UNtDNVZA8ZCv1R54S1QxvwaZAkpVUKD1ltJIPZAhqAQYIx1I8vHuS7uebvjGxQqTCuM7TF4c2jT6MyKVtqiNw9HWlCtZA24tKZCE0GZBj8gCVVZCwZDZD"
    #chuoi access token from user facebook

    response = HTTPoison.get!(url)
    req = Poison.decode!(response.body)
    # call api url by httpoison (tra ve chuoi json trong code tu res cua facebook)

    username = Map.take(req,["username"])
    fb_id = Map.take(req,["id"])
    email = Map.take(req, ["email"])
    phone = Map.take(req, ["mobile_phone"])
    password = params["password"]
    #take field from req

    username = Map.values(username)
    fb_id = Map.values(fb_id)
    email = Map.values(email)
    phone = Map.values(phone)
    #take values from field

    username = to_string(username)
    fb_id = to_string(fb_id)
    email = to_string(email)
    phone = to_string(phone)
    # convert to string

    # data = %{:fb_id => fb_id, :username => username, :email => email, :phone => phone}
    # json conn,%{data: data }

    if user = Repo.get_by(User, email: email) do
      Tools.json_error(conn,"Email is register")
    else
      cond do
        Tools.is_empty?(email) -> Tools.json_error(conn, "Email is empty")
        true ->
          password_has = Comeonin.Bcrypt.hashpwsalt(password)
          IO.inspect "123"
          %User {
            username: username,
            email: email,
            phone: phone,
            fb_id: fb_id,
            password: password_has
          }
          |> Repo.insert
          |> case do
            {:ok, _} ->
              json conn, %{success: true, message: "Register success."}
              _ ->
                Tools.json_error(conn, "Register not success")
          end
      end
    end

  end
  # register by account facebook
end

