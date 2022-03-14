defmodule MinitwitElixirWeb.PageControllerTest do
  use MinitwitElixirWeb.ConnCase
  import MinitwitElixirWeb.FlashHelper

  #tests
  test "register", %{conn: conn} do
    data = [
      user: [
        username: "user1",
        pw_1: "default",
        pw_2: "default",
        email: "user1@example.com"
      ]
    ]

    data2 = [
      user: [
        username: "",
        pw_1: "default",
        pw_2: "default",
        email: "user1@example.com"
      ]
    ]

    data3 = [
      user: [
        username: "meh",
        pw_1: "",
        pw_2: "default",
        email: "user1@example.com"
      ]
    ]

    data4 = [
      user: [
        username: "meh",
        pw_1: "x",
        pw_2: "y",
        email: "user1@example.com"
      ]
    ]

    data5 = [
      user: [
        username: "meh",
        pw_1: "foo",
        pw_2: "foo",
        email: "broken"
      ]
    ]
    conn_test = conn |> post("/register", data)
    assert flash_messages_contain(conn_test, "You were successfully registered and can login now")

    conn_test2 = conn_test |> post("/register", data)
    assert flash_messages_contain(conn_test2, "The username is already taken")

    conn_test3 = conn_test2 |> post("/register", data2)
    assert flash_messages_contain(conn_test3, "You have to enter a username")

    conn_test4 = conn_test3 |> post("/register", data3)
    assert flash_messages_contain(conn_test4, "You have to enter a password")

    conn_test5 = conn_test4 |> post("/register", data4)
    assert flash_messages_contain(conn_test5, "The two passwords do not match")

    conn_test6 = conn_test5 |> post("/register", data5)
    assert flash_messages_contain(conn_test6, "You have to enter a valid email address")
  end

  test "login_logout", %{conn: conn} do
    data = [
      user: [
        username: "user1",
        pw_1: "default",
        pw_2: "default",
        email: "user1@example.com"
      ]
    ]
    conn_test = conn
                |> post("/register", data)
                |> post("/login", [user: [username: "user1", password: "default"]])
    assert flash_messages_contain(conn_test, "You were logged in")

    conn_test2 = conn_test |> get("/logout")
    assert flash_messages_contain(conn_test2, "You were logged out")

    conn_test3 = conn_test2 |> post("/login", [user: [username: "user1", password: "wrongpassword"]])
    assert flash_messages_contain(conn_test3, "Invalid username or password")

    conn_test4 = conn_test3 |> post("/login", [user: [username: "user2", password: "wrongpassword"]])
    assert flash_messages_contain(conn_test4, "Invalid username or password")
  end

  test "message_recording", %{conn: conn} do
    data = [
      user: [
        username: "foo",
        pw_1: "default",
        pw_2: "default",
        email: "foo@example.com"
      ]
    ]
    conn_test = conn
                |> post("/register", data)
                |> post("/login", [user: [username: "foo", password: "default"]])
                |> post("/add_message", [text: "test message 1"])
                |> post("/add_message", [text: "<test message 2>"])
                |> get("/")

    assert html_response(conn_test, 200) =~ "test message 1"
    assert html_response(conn_test, 200) =~ "&lt;test message 2&gt;"
  end

  test "timelines", %{conn: conn} do
    data = [
      user: [
        username: "foo",
        pw_1: "default",
        pw_2: "default",
        email: "foo@example.com"
      ]
    ]


    data2 = [
      user: [
        username: "bar",
        pw_1: "default",
        pw_2: "default",
        email: "bar@example.com"
      ]
    ]

    conn_test = conn
                |> post("/register", data)
                |> post("/login", [user: [username: "foo", password: "default"]])
                |> post("/add_message", [text: "the message by foo"])
                |> get("/logout")
                |> post("/register", data2)
                |> post("/login", [user: [username: "bar", password: "default"]])
                |> post("/add_message", [text: "the message by bar"])

    # public timeline should show foo's and bar's messages
                |> get("/public")
    assert html_response(conn_test, 200) =~ "the message by foo"
    assert html_response(conn_test, 200) =~ "the message by bar"

    # bar's timeline should just show bar's message
    conn_test2 = conn_test |> get("/")
    refute html_response(conn_test2, 200) =~ "the message by foo"
    assert html_response(conn_test2, 200) =~ "the message by bar"

    # now let's follow foo
    conn_test3 = conn_test2 |> get("/foo/follow")
    assert flash_messages_contain(conn_test3, "You are now following foo")

    # we should now see foo's message
    conn_test4 = conn_test3 |> get("/")
    assert html_response(conn_test4, 200) =~ "the message by foo"
    assert html_response(conn_test4, 200) =~ "the message by bar"

    # but on the user's page we only want the user's message
    conn_test5 = conn_test4 |> get("/bar")
    refute html_response(conn_test5, 200) =~ "the message by foo"
    assert html_response(conn_test5, 200) =~ "the message by bar"
    conn_test6 = conn_test5 |> get("/foo")
    assert html_response(conn_test6, 200) =~ "the message by foo"
    refute html_response(conn_test6, 200) =~ "the message by bar"
    # now unfollow and check if that worked
    conn_test7 = conn_test6 |> get("/foo/unfollow")
    assert flash_messages_contain(conn_test7, "You are no longer following foo")
    conn_test8 = conn_test7 |> get("/")
    refute html_response(conn_test8, 200) =~ "the message by foo"
    assert html_response(conn_test8, 200) =~ "the message by bar"

  end
end
