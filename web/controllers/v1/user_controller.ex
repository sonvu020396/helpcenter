defmodule HelpCenter.V1.UserController do
  use HelpCenter.Web, :controller
  plug HelpCenter.API.Plugs.UserAuth when action not in [:login, :register, :register_by_account_facebook]  # call plug in controller
  # import Ecto.Query, only: [from: 2]
  alias HelpCenter.{Repo, Tools, User, Question}

  def register(conn, params) do   #ham dang ky 
    email = params["email"]  #khai bao 2 bien email & password
    password = params["password"]

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
            jwt = JsonWebToken.sign(%{id: user.id, email: user.email, password: user.password, exp: 1600819380}, %{key: conn.secret_key_base})
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
   json conn,%{data: "hello Son"}
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
    IO.inspect params 
    access_token = params["token"]    #lay chuoi access token from client
    IO.inspect access_token

    url =  "https://graph.facebook.com/me?access_token=#{access_token}"   #gan chuoi vo d/c url cua face

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.inspect "123"
      {:ok, %HTTPoison.Response{status_code: 404}} ->
       Tools.json_error(conn, "Not Found")
    end

    response = HTTPoison.get!(url)
    req = Poison.decode!(response.body)
    # call api url by httpoison (tra ve chuoi json trong code tu res cua facebook)
    
    #response["key"] -> call tung field theo object json -> review and code (not done)
    username = Map.take(req,["username"])
    fb_id = Map.take(req,["id"])
    email = Map.take(req, ["email"])
    phone = Map.take(req, ["mobile_phone"])
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
    #convert to string

    if user = Repo.get_by(User, email: email) do
      jwt = JsonWebToken.sign(%{id: user.id, email: user.email, fb_id: user.fb_id, exp: 1600819380}, %{key: conn.secret_key_base})
      data = Map.take(user,[:fb_id, :username, :email, :phone, :is_active])
      json conn, %{
        success: "Login success",
        data: data,
        token: jwt
      }
    else
      cond do
        Tools.is_empty?(email) -> Tools.json_error(conn, "Email is empty")
        true ->
          # IO.inspect "123"
          %User {
            username: username,
            email: email,
            phone: phone,
            fb_id: fb_id,
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
 #----------------------------------------------------------------------

 def create_question(conn, params) do
   title = params["title"]
   contents = params["contents"]

   cond do
    Tools.is_empty?(title) || Tools.is_empty?(contents) -> Tools.json_error(conn, "Not Empty")
    true ->
      # IO.inspect contents
      %Question {
        title: title,
        contents: contents
      }
      |> Repo.insert
      |> case do
        {:ok, _} ->
          json conn, %{
            success: "create question success",
            contents: contents
          }
          _ ->
            Tools.json_error(conn,"please create question :) ")
      end
   end 
 end
 #def create question not have image
 #----------------------------------------------------------------------

#  def create_image(conn, %{"question" => params}) do
#   changeset = Question.changeset(%Question{}, params)
#   case Repo.insert(changeset) do
#     {:ok, image} ->
#       ImageFetcher.get_image(image)
#       conn
#       |> put_flash(:info, "image created successfully")
#     {:error, _} ->
#       Tools.json_error(conn,"error upload file")
#   end
#  end

end


