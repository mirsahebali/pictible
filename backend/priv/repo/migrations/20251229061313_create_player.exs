defmodule Pictible.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :username, :string
      add :active, :boolean
      add :room_id,
        references(:rooms, on_delete: :nothing),
        null: false

      timestamps(type: :utc_datetime)
    end
  end
end
