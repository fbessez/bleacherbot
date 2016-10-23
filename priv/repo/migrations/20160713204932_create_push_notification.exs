defmodule Bleacherbot.Repo.Migrations.CreatePushNotification do
  use Ecto.Migration

  def change do
    create table(:pushnotifications) do

      timestamps()
    end

  end
end
