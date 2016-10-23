defmodule Bleacherbot.Repo.Migrations.CreateScore do
  use Ecto.Migration

  def change do
    create table(:scores) do

      timestamps()
    end

  end
end
