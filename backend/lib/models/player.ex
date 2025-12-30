defmodule Pictible.Models.Player do

  @type state :: :drawing | :erasing | :cleared | :idle

  use Ecto.Schema

  schema "players" do
    field :username, :string
    field :active, :boolean

    belongs_to :room, Pictible.Models.Room

    timestamps()
  end

  def changeset(player, params \\ %{})do
    player 
    |> Ecto.Changeset.cast(params, [:username, :active])
    |> Ecto.Changeset.validate_required([:username, :active])
  end
end
