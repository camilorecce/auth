defmodule Auth.CtxTest do
  use Auth.DataCase

  alias Auth.Ctx

  describe "roles" do
    alias Auth.Ctx.Role

    @valid_attrs %{desc: "some desc", name: "some name"}
    @update_attrs %{desc: "some updated desc", name: "some updated name"}
    @invalid_attrs %{desc: nil, name: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Ctx.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Ctx.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Ctx.create_role(@valid_attrs)
      assert role.desc == "some desc"
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Ctx.update_role(role, @update_attrs)
      assert role.desc == "some updated desc"
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_role(role, @invalid_attrs)
      assert role == Ctx.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Ctx.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Ctx.change_role(role)
    end
  end

  describe "permissions" do
    alias Auth.Ctx.Permission

    @valid_attrs %{desc: "some desc", name: "some name"}
    @update_attrs %{desc: "some updated desc", name: "some updated name"}
    @invalid_attrs %{desc: nil, name: nil}

    def permission_fixture(attrs \\ %{}) do
      {:ok, permission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_permission()

      permission
    end

    test "list_permissions/0 returns all permissions" do
      permission = permission_fixture()
      assert Ctx.list_permissions() == [permission]
    end

    test "get_permission!/1 returns the permission with given id" do
      permission = permission_fixture()
      assert Ctx.get_permission!(permission.id) == permission
    end

    test "create_permission/1 with valid data creates a permission" do
      assert {:ok, %Permission{} = permission} = Ctx.create_permission(@valid_attrs)
      assert permission.desc == "some desc"
      assert permission.name == "some name"
    end

    test "create_permission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_permission(@invalid_attrs)
    end

    test "update_permission/2 with valid data updates the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{} = permission} = Ctx.update_permission(permission, @update_attrs)
      assert permission.desc == "some updated desc"
      assert permission.name == "some updated name"
    end

    test "update_permission/2 with invalid data returns error changeset" do
      permission = permission_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_permission(permission, @invalid_attrs)
      assert permission == Ctx.get_permission!(permission.id)
    end

    test "delete_permission/1 deletes the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{}} = Ctx.delete_permission(permission)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_permission!(permission.id) end
    end

    test "change_permission/1 returns a permission changeset" do
      permission = permission_fixture()
      assert %Ecto.Changeset{} = Ctx.change_permission(permission)
    end
  end
end
