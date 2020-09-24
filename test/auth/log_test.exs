defmodule Auth.LogTest do
  use AuthWeb.ConnCase
  alias Auth.UserAgent
  require Logger

  test "Auth.Log.error/2 inserts error log into db", %{conn: conn} do
    conn =
      conn
      |> Auth.UserAgent.assign_ua()
      |> AuthWeb.AuthController.not_found("no content")

    assert conn.status == 404

    ua = UserAgent.upsert(conn)
    ua_string = UserAgent.make_ua_string(ua)

    assert conn.assigns.ua == ua_string

    log = List.last(Auth.Log.get_all())
    assert log.status_id == 404
  end
end
