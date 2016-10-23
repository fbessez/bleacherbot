defmodule Bleacherbot.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do

      timestamps()
    end

  end
end
