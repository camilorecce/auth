defmodule AuthWeb.AppControllerTest do
  use AuthWeb.ConnCase

  alias Auth.{App, Role}

  @create_attrs %{
    desc: "some description",
    end: ~N[2010-04-17 14:00:00],
    name: "some name",
    url: "some url",
    status: 3,
    person_id: 1
  }
  @update_attrs %{
    desc: "some updated description",
    end: ~N[2011-05-18 15:01:01],
    name: "some updated name",
    url: "some updated url"
  }
  @invalid_attrs %{description: nil, end: nil, name: nil, url: nil, person_id: nil}

  def fixture(:app) do
    {:ok, app} = App.create_app(@create_attrs)
    app
  end

  describe "index" do
    setup [:create_app]

    test "lists all apps", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :index))
      assert html_response(conn, 200) =~ "Apps"
    end

    test "non-admin cannot see admin apps", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :index))
      assert html_response(conn, 200) =~ "Apps"
      # the non-admin cannot see the app created in setup:
      assert not String.contains?(conn.resp_body, app.name)
    end
  end

  describe "new app" do
    test "renders form", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :new))
      assert html_response(conn, 200) =~ "New App"
    end
  end

  describe "create app" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.app_path(conn, :create), app: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.app_path(conn, :show, id)

      conn = get(conn, Routes.app_path(conn, :show, id))
      assert html_response(conn, 200) =~ "App"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.app_path(conn, :create), app: @invalid_attrs)
      assert html_response(conn, 200) =~ "New App"
    end
  end

  describe "show app" do
    setup [:create_app]

    test "attempt to VIEW app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :show, app))
      assert html_response(conn, 404) =~ "can't touch this."
    end
  end

  describe "edit app" do
    setup [:create_app]

    test "renders form for editing chosen app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :edit, app))
      assert html_response(conn, 200) =~ "Edit App"
    end

    test "attempt to EDIT app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :edit, app))
      assert html_response(conn, 404) =~ "can't touch this."
    end
  end

  describe "update app" do
    setup [:create_app]

    test "redirects when data is valid", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = put(conn, Routes.app_path(conn, :update, app), app: @update_attrs)
      assert redirected_to(conn) == Routes.app_path(conn, :show, app)

      conn = get(conn, Routes.app_path(conn, :show, app))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = put(conn, Routes.app_path(conn, :update, app), app: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit App"
    end

    test "attempt UPDATE app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = put(conn, Routes.app_path(conn, :update, app), app: @update_attrs)
      assert html_response(conn, 404) =~ "can't touch this."
    end
  end

  describe "delete app" do
    setup [:create_app]

    test "deletes chosen app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = delete(conn, Routes.app_path(conn, :delete, app))
      assert redirected_to(conn) == Routes.app_path(conn, :index)

      assert_error_sent 500, fn ->
        get(conn, Routes.app_path(conn, :show, app))
      end
    end

    test "attempt DELETE app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = delete(conn, Routes.app_path(conn, :delete, app))
      assert html_response(conn, 404) =~ "can't touch this."
    end
  end

  defp create_app(_) do
    app = fixture(:app)
    %{app: app}
  end

  describe "reset apikey" do
    setup [:create_app]

    test "reset apikey for an app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :resetapikey, app))
      assert html_response(conn, 200) =~ "successfully reset"
    end

    test "attempt reset apikey you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :resetapikey, app))
      assert html_response(conn, 404) =~ "can't touch this."
    end
  end

  describe "GET /approles/:client_id" do
    setup [:create_app]

    test "returns 401 if client_id is invalid", %{conn: conn} do
      conn = conn
      |> put_req_header("accept", "application/json")
      |> get("/approles/invalid")

      assert html_response(conn, 401) =~ "invalid"
    end

    test "returns (JSON) list of roles", %{conn: conn, app: app} do
      roles = Auth.Role.list_roles_for_app(app.id)
      key = List.first(app.apikeys)
      # IO.inspect(app, label: "app")
      conn = conn
      |> admin_login()
      |> put_req_header("accept", "application/json")
      |> get("/approles/#{key.client_id}")

      assert conn.status == 200
      {:ok, json} = Jason.decode(conn.resp_body)
      # IO.inspect(json)
      assert length(roles) == length(json)
      # assert html_response(conn, 200) =~ "successfully reset"
    end

    test "returns only relevant roles", %{conn: conn, app: app} do
      roles = Role.list_roles_for_app(app.id)
      # admin create role:
      admin_role = %{desc: "admin role", name: "new admin role", app_id: app.id}
      {:ok, %Role{} = admin_role} = Role.create_role(admin_role)
      # check that the new role was added to the admin app role list:
      roles2 = Role.list_roles_for_app(app.id)
      assert length(roles) < length(roles2)
      last = List.last(roles2)
      assert last.name == admin_role.name


      # login as non-admin person
      conn2 = non_admin_login(conn)

      # create non-admin app (to get API Key)
      {:ok, non_admin_app} = Auth.App.create_app(%{
        "name" => "default system app",
        "desc" => "Demo App",
        "url" => "localhost:4000",
        "person_id" => conn2.assigns.person.id,
        "status" => 3
      })
      # create non-admin role:
      role_data = %{
        desc: "non-admin role", name: "non-admin role",
        app_id: non_admin_app.id
      }
      {:ok, %Role{} = role2} = Role.create_role(role_data)
      key = List.first(non_admin_app.apikeys)

      conn3 = conn2
      |> admin_login()
      |> put_req_header("accept", "application/json")
      |> get("/approles/#{key.client_id}")

      assert conn3.status == 200
      {:ok, json} = Jason.decode(conn3.resp_body)
      last_role = List.last(json)
      # confirm the last role in the list is the new non-admin role:
      assert Map.get(last_role, "name") == role2.name

      # confirm the admin_role is NOT in the JSON reponse:
      should_be_empty = Enum.filter(json, fn r ->
        Map.get(r, "name") == admin_role.name
      end)
      assert length(should_be_empty) == 0
    end
  end
end
