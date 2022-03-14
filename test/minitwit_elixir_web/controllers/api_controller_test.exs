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
                |> put_req_header("authorization", "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh")
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

    msg_query_data = %{
      "no" => "20",
      "latest" => "3"
    }

    msg_data = %{
      "content" => "Blub!",
      "latest" => "2"
    }

    conn_test = conn
                |> put_req_header("content-type", "application/json")
                |> put_req_header("authorization", "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh")
                |> post("/api/register", register_data)

    conn_test2 = conn_test
                |> post("/api/msgs/a", msg_data)

    conn_test3 = conn_test2
                |> get("/api/msgs/a", msg_query_data)

    json_response(conn_test3, 200) == [
      %{
        "content" => "Blub!",
        "user" => "a"
      }
    ]

  end

  test "get latest messages", %{conn: conn} do

    register_data = %{
      "username" => "a",
      "email" => "a@a.a",
      "pwd" => "a",
      "latest" => "1"
    }

    msg_query_data = %{
      "no" => "20",
      "latest" => "3"
    }

    msg_data = %{
      "content" => "Blub!",
      "latest" => "2"
    }

    conn_test = conn
                |> put_req_header("content-type", "application/json")
                |> put_req_header("authorization", "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh")
                |> post("/api/register", register_data)

    conn_test2 = conn_test
                 |> post("/api/msgs/a", msg_data)

    conn_test3 = conn_test2
                 |> get("/api/msgs/", msg_query_data)

    json_response(conn_test3, 200) == [
      %{
        "content" => "Blub!",
        "user" => "a"
      }
    ]

  end

  test "register b", %{conn: conn} do
    data = [
      username: "b",
      email: "b@b.b",
      pwd: "b",
      latest: "5"
    ]
    conn_test = conn |>
      post("/api/register", data)
    assert text_response(conn_test, 204)

    conn_test2 = conn_test |>
      get("/api/latest")
    assert json_response(conn_test2, 200) == %{"latest" => 5}

  end

  test "register c", %{conn: conn} do
    data = [
      username: "c",
      email: "c@c.c",
      pwd: "c",
      latest: "6"
    ]
    conn_test = conn |>
      post("/api/register", data)
    assert text_response(conn_test, 204)

    conn_test2 = conn_test |>
      get("/api/latest")
    assert json_response(conn_test2, 200) == %{"latest" => 6}

  end

  test "follow user", %{conn: conn} do
    #register users
    data_a = [
      username: "a",
      email: "a@a.a",
      pwd: "a",
      latest: "1"
    ]

    data_b = [
      username: "b",
      email: "b@b.b",
      pwd: "b",
      latest: "5"
    ]

    data_c = [
      username: "c",
      email: "c@c.c",
      pwd: "c",
      latest: "6"
    ]
    conn_test = conn |>
      put_req_header("authorization", "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh") |>
      post("/api/register", data_a)

    conn_test2 = conn_test |>
      post("/api/register", data_b)

    conn_test3 = conn_test2 |>
      post("/api/register", data_c)

    #a follows b and c
    data_follow_ab = [
      follow: "b",
      latest: "7"
    ]

    data_follow_ac = [
      follow: "c",
      latest: "8"
    ]

    data_confirm = [
      no: "20",
      latest: "9"
    ]

    conn_test4 = conn_test3 |>
      post("/api/fllws/a", data_follow_ab)
    assert text_response(conn_test4, 204)

    conn_test5 = conn_test4 |>
      post("/api/fllws/a", data_follow_ac)
    assert text_response(conn_test5, 204)

    conn_test6 = conn_test5 |>
      get("/api/fllws/a", data_confirm)
    assert Enum.at(json_response(conn_test6, 200)["follows"], 0) == "b"
    assert Enum.at(json_response(conn_test6, 200)["follows"], 1) == "c"

    # verify that latest was updated
    conn_test7 = conn_test6 |>
      get("/api/latest")
    assert json_response(conn_test7, 200) == %{"latest" => 9}

  end

  test "a unfollows b", %{conn: conn} do
    #register users
    data_a = [
      username: "a",
      email: "a@a.a",
      pwd: "a",
      latest: "1"
    ]

    data_b = [
      username: "b",
      email: "b@b.b",
      pwd: "b",
      latest: "5"
    ]

    data_c = [
      username: "c",
      email: "c@c.c",
      pwd: "c",
      latest: "6"
    ]
    conn_test = conn |>
      put_req_header("authorization", "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh") |>
      post("/api/register", data_a) |>
      post("/api/register", data_b) |>
      post("/api/register", data_c)

    #a follows b and c
    data_follow_ab = [
      follow: "b",
      latest: "7"
    ]

    data_follow_ac = [
      follow: "c",
      latest: "8"
    ]

    data_confirm = [
      no: "20",
      latest: "9"
    ]

    conn_test2 = conn_test |>
      post("/api/fllws/a", data_follow_ab) |>
      post("/api/fllws/a", data_follow_ac)

    #a unfollows b
    data_unfollow_ab = [
      unfollow: "b",
      latest: "10"
    ]

    data_confirm_2 = [
      no: "20",
      latest: "11"
    ]

    conn_test3 = conn_test2 |>
      post("/api/fllws/a", data_unfollow_ab)
    assert text_response(conn_test3, 204)

    conn_test4 = conn_test3 |>
      get("/api/fllws/a", data_confirm_2)
    refute Enum.at(json_response(conn_test4, 200)["follows"], 0) == "b"
    assert Enum.at(json_response(conn_test4, 200)["follows"], 0) == "c"

    # verify that latest was updated
    conn_test5 = conn_test4 |>
      get("/api/latest")
    assert json_response(conn_test5, 200) == %{"latest" => 11}

  end

end
