defmodule MinitwitElixirWeb.ApiControllerTest do
  use MinitwitElixirWeb.ConnCase

  test "latest", %{conn: conn} do

    data = %{
      "username" => "test",
      "email" => "test@test",
      "pwd" => "foo",
      "latest" => "1337"
    }

    # post something to update LATEST
    conn_test = conn
                |> put_req_header("content-type", "application/json")
                |> post(Routes.register_path(conn, :register), data)
    assert text_response(conn_test, 204)

    # verify that latest was updated
    conn_test2 = conn_test
                 |> get(Routes.timeline_path(conn_test, :latest))
    assert json_response(conn_test2, 200) == %{"latest" => 1337}
  end

  test "register a", %{conn: conn} do

    data = %{
      "username" => "a",
      "email" => "a@a.a",
      "pwd" => "a",
      "latest" => "1"
    }

    conn_test = conn
                |> put_req_header("content-type", "application/json")
                |> post("/api/register", data)
    assert text_response(conn_test, 204)
    # TODO: add another assertion that it is really there
    #conn_test2 = conn_test
    #            |> post("/api/register", data)
    #assert json_response(conn_test2, 400)

    # verify that latest was updated
    conn_test3 = conn_test
                 |> get("/api/latest")
    assert json_response(conn_test3, 200) == %{"latest" => 1}
  end

  test "create message", %{conn: conn} do
    register_data = %{
      "username" => "a",
      "email" => "a@a.a",
      "pwd" => "a",
      "latest" => "1"
    }
    msg_data = %{
      "content" => "Blub!",
      "latest" => "2"
    }
    conn_test = conn
                |> put_req_header("content-type", "application/json")
                |> post("/api/register", register_data)

    conn_test2 = conn_test
                  |> post("/api/msgs/a", msg_data)
    assert text_response(conn_test2, 204)

    # verify that latest was updated
    conn_test3 = conn_test2
                 |> get("/api/latest")
    assert json_response(conn_test3, 200) == %{"latest" => 2}

  end

  test "get latest user messages", %{conn: conn} do
    register_data = %{
      "username" => "a",
      "email" => "a@a.a",
      "pwd" => "a",
      "latest" => "1"
    }

    msg_data = %{
      "no" => "20",
      "latest" => "3"
    }

    conn_test = conn
                |> put_req_header("content-type", "application/json")
                |> post("/api/register", register_data)

    conn_test2 = conn_test
                |> get("/api/msgs/a", msg_data)
    assert json_response(conn_test2, 200)

    json_result = json_response(conn_test2, 200)
    #assert Enum.member?(json_result, msg_data = %{
    #  "content" => "Blob!",
    #  "user" => "a"
    #})
    IO.puts(Enum.empty?(json_result))

  end

  test "get latest messages", %{conn: conn} do

  end

end