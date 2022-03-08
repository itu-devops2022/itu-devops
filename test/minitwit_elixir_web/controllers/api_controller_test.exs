defmodule MinitwitElixirWeb.ApiControllerTest do
  use MinitwitElixirWeb.ConnCase

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

  end

end
