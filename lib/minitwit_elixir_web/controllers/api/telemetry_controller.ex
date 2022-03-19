defmodule MinitwitElixirWeb.Api.TelemetryController do
  use MinitwitElixirWeb, :controller
  use Phoenix.Controller

  def export_metric(conn, _params) do
    #IO.inspect("exporting metrics")
    conn |>
      put_status(200) |>
      text("exporting metrics")
  end

  def import_metric(conn, params) do
    IO.inspect("importing metrics: #{params["metrics"]}")
    conn |>
      put_status(200) |>
      text("importing metrics")
  end

end
