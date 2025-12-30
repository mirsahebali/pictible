defmodule Pictible.Models.Room do

  @type state :: :drawing | :erasing | :cleared | :idle

  use Ecto.Schema

  schema "rooms" do
    field :room_code, :string

    has_many :players, Pictible.Models.Player

    timestamps()
  end

  def changeset(room, params \\ %{})do
    room 
    |> Ecto.Changeset.cast(params, [:room_code])
    |> Ecto.Changeset.validate_required([:room_code])
  end
end
