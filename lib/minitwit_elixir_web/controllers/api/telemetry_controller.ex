defmodule MinitwitElixirWeb.Api.TelemetryController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller

  def export_metric(conn, _params) do
    #IO.inspect("exporting metrics")
    case File.read("metrics") do
      {:ok, body} ->
        conn |>
          put_status(200) |>
          json(%{metrics: body})
      {:error, reason} ->
        conn |>
          put_status(503) |>
          json(%{error_msg: reason})
    end

  end

  def import_metric(conn, params) do
    IO.inspect("importing metrics: #{params["metrics"]}")
    {:ok, file} = File.open("metrics", [:write])
    IO.binwrite(file, params["metrics"])
    File.close(file)
    conn |>
      put_status(200) |>
      text("importing metrics")
  end

end
