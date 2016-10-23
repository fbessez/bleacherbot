defmodule Bleacherbot.Repo.Migrations.CreateTrack do
  use Ecto.Migration

  def change do
    create table(:tracks) do

      timestamps()
    end

  end
end
