defmodule HelpCenter.Tools do

  # def is_email(email) do
  # end
  
  def is_empty?(text) when is_nil(text), do: true

  def append_map_key(map, key, value) do
    if key && value do
      Map.put(map, key, value)
    else
      map
    end
  end
  
  def json_error(conn, message, code \\ 400) do
    response = %{success: false}
    |> append_map_key(:message, message)
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=UTF-8")
    |> Plug.Conn.send_resp(code, Poison.encode!(response))
    |> Plug.Conn.halt
  end

  # defp hash_password(model) do
  #   case get_change(model, :password) do
  #     nil -> model
  #     password -> put_change(model, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
  #   end
  # end

end