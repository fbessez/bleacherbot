defmodule Bleacherbot.PushNotificationController do
  use Bleacherbot.Web, :controller

  # alias Bleacherbot.PushNotification

  def index(conn, %{"permalink" => params}) do
    pushnotifications = BleacherBot.LastPush.fetch_pushes(params)
    render(conn, "index.json", pushnotifications: pushnotifications)
  end

  def index(conn, _) do
    conn
    |> send_resp(400, "permalink required")
  end

  # def create(conn, %{"push_notification" => push_notification_params}) do
  #   changeset = PushNotification.changeset(%PushNotification{}, push_notification_params)

  #   case Repo.insert(changeset) do
  #     {:ok, push_notification} ->
  #       conn
  #       |> put_status(:created)
  #       |> put_resp_header("location", push_notification_path(conn, :show, push_notification))
  #       |> render("show.json", push_notification: push_notification)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  def show(conn, %{"id" => unique_name}) do
    push_notification = BleacherBot.LastPush.fetch_pushes(unique_name)
    render(conn, "show.json", push_notification: push_notification)
  end

  # def update(conn, %{"id" => unique_name, "push_notification" => push_notification_params}) do
  #   push_notification = BleacherBot.LastPush.fetch_pushes(unique_name)
  #   changeset = PushNotification.changeset(push_notification, push_notification_params)

  #   case Repo.update(changeset) do
  #     {:ok, push_notification} ->
  #       render(conn, "show.json", push_notification: push_notification)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => unique_name}) do
  #   push_notification = BleacherBot.LastPush.fetch_pushes(unique_name)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(push_notification)

  #   send_resp(conn, :no_content, "")
  # end
end
