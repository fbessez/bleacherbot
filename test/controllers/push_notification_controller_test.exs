defmodule Bleacherbot.PushNotificationControllerTest do
  use Bleacherbot.ConnCase

  alias Bleacherbot.PushNotification
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, push_notification_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    push_notification = Repo.insert! %PushNotification{}
    conn = get conn, push_notification_path(conn, :show, push_notification)
    assert json_response(conn, 200)["data"] == %{"id" => push_notification.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, push_notification_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, push_notification_path(conn, :create), push_notification: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(PushNotification, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, push_notification_path(conn, :create), push_notification: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    push_notification = Repo.insert! %PushNotification{}
    conn = put conn, push_notification_path(conn, :update, push_notification), push_notification: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(PushNotification, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    push_notification = Repo.insert! %PushNotification{}
    conn = put conn, push_notification_path(conn, :update, push_notification), push_notification: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    push_notification = Repo.insert! %PushNotification{}
    conn = delete conn, push_notification_path(conn, :delete, push_notification)
    assert response(conn, 204)
    refute Repo.get(PushNotification, push_notification.id)
  end
end
