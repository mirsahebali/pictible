defmodule Pictible.Repo.Migrations.CreateRoom do

  @exp_minutes 30

  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :room_code, :string
      add :expires_at, :utc_datetime, default: DateTime.add(DateTime.utc_now(), @exp_minutes, :minute)

      timestamps(type: :utc_datetime)
    end
  end
end
