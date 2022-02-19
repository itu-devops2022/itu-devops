defmodule MinitwitElixirWeb.PageControllerTest do
  use MinitwitElixirWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end


  #Helper functions
  def register(conn, username, password, password2 \\ nil, email \\ nil) do
    unless (password2) do
      password2 = password
    end

    unless (email) do
      email = username<>"@example.com"
    end

    data = [
      username: username,
      password: password,
      password2: password2,
      email: email
    ]

    post(conn, "/register", data)
  end

  def login(conn, username, password) do
    post(conn, "/login", [username: username, password: password])
  end

  def register_and_login(conn, username, password) do
    register(conn, username, password, nil, nil)
    |> login(username, password)
  end

  def logout(conn) do
    get(conn, "/logout")
  end

  def add_message(conn, text) do
    post(conn, "/add_message", [text: text])
  end

  #tests
  test "register", %{conn: conn} do
    conn = register(conn, "user1", "default")
    assert get_flash(conn, :info) =~ "You were successfully registered and can login now"

    conn = register(conn, "user1", "default")
    assert get_flash(conn, :info) =~ "The username is already taken"

    conn = register(conn, "", "default")
    assert get_flash(conn, :info) =~ "You have to enter a username"

    conn = register(conn, "meh", "")
    assert get_flash(conn, :info) =~ "You have to enter a password"

    conn = register(conn, "meh", "x", "y")
    assert get_flash(conn, :info) =~ "The two passwords do not match"

    conn = register(conn, "meh", "foo", "foo", "broken")
    assert get_flash(conn, :info) =~ "You have to enter a valid email address"
  end

  test "login_logout", %{conn: conn} do
    conn = register_and_login(conn, "user1", "default")
    assert get_flash(conn, :info) =~ "You were logged in"

    conn = logout(conn)
    assert get_flash(conn, :info) =~ "You were logged out"

    conn = login(conn, "user1", "wrongpassword")
    assert get_flash(conn, :info) =~ "Invalid password"

    conn = login(conn, "user2", "wrongpassword")
    assert get_flash(conn, :info) =~ "Invalid username"
  end

  test "message_recording", %{conn: conn} do
    conn = register_and_login(conn, "foo", "default")
    conn = add_message(conn, "test message 1")
    conn = add_message(conn, "<test message 2>")

    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "test message 1"
    assert html_response(conn, 200) =~ "&lt;test message 2&gt;"
  end

  test "timelines", %{conn: conn} do
    conn = register_and_login(conn, "foo", "default")
    conn = add_message(conn, "the message by foo")
    conn = logout(conn)
    conn = register_and_login(conn, "bar", "default")
    conn = add_message(conn, "the message by bar")

    # public timeline should show foo's and bar's messages
    conn = get(conn, "/public")
    assert html_response(conn, 200) =~ "the message by foo"
    assert html_response(conn, 200) =~ "the message by bar"

    # bar's timeline should just show bar's message
    conn = get(conn, "/")
    refute html_response(conn, 200) =~ "the message by foo"
    assert html_response(conn, 200) =~ "the message by bar"

    # now let's follow foo
    conn = get(conn, "/foo/follow")
    assert get_flash(conn, :info) =~ "You are now following &#34;foo&#34;"

    # we should now see foo's message
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "the message by foo"
    assert html_response(conn, 200) =~ "the message by bar"

    # but on the user's page we only want the user's message
    conn = get(conn, "/bar")
    refute html_response(conn, 200) =~ "the message by foo"
    assert html_response(conn, 200) =~ "the message by bar"
    conn = get(conn, "/bar")
    assert html_response(conn, 200) =~ "the message by foo"
    refute html_response(conn, 200) =~ "the message by bar"

    # now unfollow and check if that worked
    conn = get(conn, "/foo/unfollow")
    assert get_flash(conn, :info) =~ "You are no longer following &#34;foo&#34;"
    conn = get(conn, "/")
    refute html_response(conn, 200) =~ "the message by foo"
    assert html_response(conn, 200) =~ "the message by bar"

  end
end
