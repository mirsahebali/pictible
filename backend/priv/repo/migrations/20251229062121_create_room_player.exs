defmodule Pictible.Repo.Migrations.CreateRoom do

  use Ecto.Migration

  @exp_minutes 30

  def change do
    create table(:players) do
      add :username, :string
      add :active, :boolean
      add :room_id,
        references(:rooms, on_delete: :nothing),
        null: true 

      timestamps(type: :utc_datetime)
    end

    create table(:rooms) do
      add :room_code, :string
      add :expires_at, :utc_datetime, default: DateTime.add(DateTime.utc_now(), @exp_minutes, :minute)

      timestamps(type: :utc_datetime)
    end
  end
end
