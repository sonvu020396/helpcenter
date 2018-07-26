defmodule HelpCenter.Tools do

  def is_email(email) when is_binary(email) do
    case Regex.run(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, email) do
      nil ->
        {:error, "Invalid email"}
      [email] ->
        try do
          Regex.run(~r/(\w+)@([\w.]+)/, email) |> validate_email
        rescue
          _ -> {:error, "Invalid email"}
        end
    end
  end
  
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

end