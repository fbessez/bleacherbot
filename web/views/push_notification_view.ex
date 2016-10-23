defmodule Bleacherbot.PushNotificationView do
  use Bleacherbot.Web, :view

  def render("index.json", %{pushnotifications: pushnotifications}) do
    %{"push_notifications": pushnotifications}
    #render_many(pushnotifications, Bleacherbot.PushNotificationView, "push_notification.json")
  end

  def render("show.json", params) do
    %{"push_notifications": params.push_notification}
    #render_one(push_notification, Bleacherbot.PushNotificationView, "push_notification.json")
  end

  def render("push_notification.json", %{push_notification: push_notification}) do
    %{id: push_notification}
  end
end
