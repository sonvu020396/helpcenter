defmodule HelpCenter.Tools do  

  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
  def is_valid_email(email) when is_nil(email), do: false
  def is_valid_email(email) when is_binary(email) do
    case Regex.run(@email_regex, email) do
      nil -> false
      [_] -> true
    end
  end

  def is_empty?(text) when is_nil(text), do: true
  def is_empty?([]), do: true
  def is_empty?(map) when is_map(map), do: (if map == %{}, do: true, else: false)
  def is_empty?(text) when text == "", do: true
  def is_empty?(text) when text == "undefined", do: true
  def is_empty?(_text), do: false

  def get_access_token_from_params(conn) do
    authorization = List.first(Plug.Conn.get_req_header(conn, "authorization"))
    #IO.inspect authorization
    if !is_nil(authorization) do
      parts = String.split(authorization, " ")
      if Enum.at(parts, 0) == "Bearer" do
        Enum.at(parts, 1)
      else
        nil
      end
    end
  end

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

end