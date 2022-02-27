defmodule MinitwitElixirWeb.PageControllerTest do
  use MinitwitElixirWeb.ConnCase
  import MinitwitElixirWeb.FlashHelper

  #tests
  test "register", %{conn: conn} do
    data = [
      username: "user1",
      password: "default",
      password2: "default",
      email: "default@example.com"
    ]

    data2 = [
      username: "",
      password: "default",
      password2: "default",
      email: "default@example.com"
    ]

    data3 = [
      username: "meh",
      password: "",
      password2: "default",
      email: "default@example.com"
    ]

    data4 = [
      username: "meh",
      password: "x",
      password2: "y",
      email: "default@example.com"
    ]

    data5 = [
      username: "meh",
      password: "foo",
      password2: "foo",
      email: "broken"
    ]
    conn_test = conn |> post("/register", data)
    conn_test |> flash_messages_contain("You were successfully registered and can login now")

    conn_test2 = conn_test |> post("/register", data)
    conn_test2 |> flash_messages_contain("The username is already taken")

    conn_test3 = conn_test2 |> post("/register", data2)
    conn_test3 |> flash_messages_contain("You have to enter a username")

    conn_test4 = conn_test3 |> post("/register", data3)
    conn_test4 |> flash_messages_contain("You have to enter a password")

    conn_test5 = conn_test4 |> post("/register", data4)
    conn_test5 |> flash_messages_contain("The two passwords do not match")

    conn_test6 = conn_test5 |> post("/register", data5)
    conn_test6 |> flash_messages_contain("You have to enter a valid email address")
  end

  test "login_logout", %{conn: conn} do
    data = [
      username: "user1",
      password: "default",
      password2: "default",
      email: "default@example.com"
    ]
    conn_test = conn
                |> post("/register", data)
                |> post("/login", [username: "user1", password: "default"])
    conn_test |> flash_messages_contain("You were successfully registered and can login now")
    conn_test |> flash_messages_contain("You were logged in")

    conn_test2 = conn_test |> get("/logout")
    conn_test2 |> flash_messages_contain("You were logged out")

    conn_test3 = conn_test2 |> post("/login", [username: "user1", password: "wrongpassword"])
    conn_test3 |> flash_messages_contain("Invalid password")

    conn_test4 = conn_test3 |> post("/login", [username: "user2", password: "wrongpassword"])
    conn_test4 |> flash_messages_contain("Invalid username")
  end

  test "message_recording", %{conn: conn} do
    #data = [
    #  username: "foo",
    #  password: "default",
    #  password2: "default",
    #  email: "default@example.com"
    #]
    #conn_test = conn
    #            |> post("/register", data)
    #            |> post("/login", [username: "foo", password: "default"])
    #            |> post("/add_message", [text: "test message 1"])
    #            |> post("/add_message", [text: "<test message 2>"])
#
    #assert redirected_to(conn_test, 302) == "/"
    #conn_test_redir = get(recycle(conn_test), "/")
    #assert html_response(conn_test_redir, 302) =~ "test message 1"
    #assert html_response(conn_test_redir, 302) =~ "&lt;test message 2&gt;"
  end

  test "timelines", %{conn: conn} do
    #data = [
    #  username: "foo",
    #  password: "default",
    #  password2: "default",
    #  email: "default@example.com"
    #]
#
    #data2 = [
    #  username: "bar",
    #  password: "default",
    #  password2: "default",
    #  email: "default@example.com"
    #]
#
    #conn_test = conn
    #            |> post("/register", data)
    #            |> post("/login", [username: "foo", password: "default"])
    #            |> post("/add_message", "the message by foo")
    #            |> get("/logout")
    #            |> post("/register", data2)
    #            |> post("/login", [username: "bar", password: "default"])
    #            |> post("/add_message", "the message by bar")
#
    ## public timeline should show foo's and bar's messages
    #            |> get("/public")
    #assert html_response(conn_test, 200) =~ "the message by foo"
    #assert html_response(conn_test, 200) =~ "the message by bar"
#
    ## bar's timeline should just show bar's message
    #conn_test2 = conn_test |> get("/")
    #refute html_response(conn_test2, 200) =~ "the message by foo"
    #assert html_response(conn_test2, 200) =~ "the message by bar"
#
    ## now let's follow foo
    #conn_test3 = conn_test2 |> get("/foo/follow")
    #conn_test3 |> flash_messages_contain("You are now following &#34;foo&#34;")
#
    ## we should now see foo's message
    #conn_test4 = conn_test3 |> get("/")
    #assert html_response(conn_test4, 200) =~ "the message by foo"
    #assert html_response(conn_test4, 200) =~ "the message by bar"
#
    ## but on the user's page we only want the user's message
    #conn_test5 = conn_test4 |> get("/bar")
    #refute html_response(conn_test5, 200) =~ "the message by foo"
    #assert html_response(conn_test5, 200) =~ "the message by bar"
    #conn_test6 = conn_test5 |> get("/foo")
    #assert html_response(conn_test6, 200) =~ "the message by foo"
    #refute html_response(conn_test6, 200) =~ "the message by bar"
#
    ## now unfollow and check if that worked
    #conn_test7 = conn_test6 |> get("/foo/unfollow")
    #conn_test7 |> flash_messages_contain("You are no longer following &#34;foo&#34;")
    #conn_test8 = conn_test7 |> get("/")
    #refute html_response(conn_test8, 200) =~ "the message by foo"
    #assert html_response(conn_test8, 200) =~ "the message by bar"

  end
end
