defmodule Bleacherbot.PushNotificationTest do
  use Bleacherbot.ModelCase

  alias Bleacherbot.PushNotification

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PushNotification.changeset(%PushNotification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PushNotification.changeset(%PushNotification{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule BleacherBot.LastPushTest do
  use Bleacherbot.ModelCase

  alias BleacherBot.LastPush

  test "fetch_pushes/2 with valid attributes and a recent push notification" do
    data = LastPush.fetch_pushes("kobe-bryant") # a real permalink
    assert (length data) ==== 1
  end

  test "fetch_pushes/2 with valid attributes and N pushes requested" do
    data = LastPush.fetch_pushes("kobe-bryant", 3)
    assert (length data) === 3
  end

  test "fetch_pushes/2 with valid attributes but no recent push notification" do
    data = LastPush.fetch_pushes("larry-bird", 2)  # a real permalink
    assert data === "Invalid permalink"
  end

  test "fetch_pushes/2 with invalid attributes" do
    data = LastPush.fetch_pushes("fabien-bessez")
    assert data === "Invalid permalink"
  end

  test "fetch_response/1 with valid unique name" do
    response = LastPush.fetch("kobe-bryant")
    assert response.body !== "[]"
  end

  test "fetch_response/1 with invalid unique name" do
    response = LastPush.fetch("HouseOfCards") do
    assert response.body === "[]"
  end


end
