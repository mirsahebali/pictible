defmodule Pictible.Repo.Migrations.AddChatSystem do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :message, :string, null: false
      add :sent_at, :utc_datetime, null: false
      add :player_id, references(:players), null: false
      add :room_id, references(:rooms), null: false
    end

    create index(:chats, [:room_id])
    create index(:chats, [:player_id])
  end
end
