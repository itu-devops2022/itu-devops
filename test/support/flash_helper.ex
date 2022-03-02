defmodule MinitwitElixirWeb.FlashHelper do
  @moduledoc false

  def flash_messages_contain(conn, text) do
    conn
    |> Phoenix.Controller.get_flash()
    |> Enum.any?(fn(item) -> String.contains?(elem(item, 1), text) end)
  end

end