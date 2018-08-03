defmodule HelpCenter.API.Plugs.UserAuth do
  import Plug.Conn
  alias HelpCenter.{ Tools, User, Repo }

  def init(opts), do: opts

  def call(conn, _) do
   #IO.inspect conn
    case Tools.get_access_token_from_params(conn) do
      nil -> Tools.json_error(conn, "Thiếu access_token", 400) 
      access_token ->
        IO.inspect access_token
        case validate_access_token(conn, access_token) do
          :invalid_token -> Tools.json_error(conn, "Sai access_token", 400)
          :expired_token -> Tools.json_error(conn, "access_token đã hết hạn", 400)
          :deleted -> Tools.json_error(conn, "Tài khoản không tồn tại hoặc đã bị khoá.", 404)
          assigned_conn -> assigned_conn
          IO.inspect assigned_conn
        end
    end
  end

  def validate_access_token(conn, access_token) do
    IO.inspect access_token 
    try do
      IO.inspect "123"
      IO.inspect JsonWebToken.verify(access_token, %{key: conn.secret_key_base})
      IO.inspect conn.secret_key_base
      case JsonWebToken.verify(access_token, %{key: conn.secret_key_base}) do #kien tra token dung hay hk
        {:ok, claims} ->
          IO.inspect "456"
          current_timestamp = DateTime.to_unix(DateTime.utc_now())  #gan curentt bang thoi gian hien tai
          IO.inspect current_timestamp
          cond do
            claims.exp > current_timestamp ->  #so sanh thoi gian song cua toekn voi thoi gian hien tai
              user_id = claims.id  #gan user_id bang id user cua token
              Repo.get(User, user_id)  #kiem tra id user
              |> case do
                nil -> :invalid_token  # sai token
                user ->   
                  assign(conn, :current_user, user)  #tra ve thong tin user, gan thong tin user vao bien current_user qua ham assign
              end
            true -> :expired_token  
          end
        {:error, _} -> :invalid_token
        #IO.inspect "112"
      end
    rescue
        RuntimeError -> :invalid_token
    end
  end

end