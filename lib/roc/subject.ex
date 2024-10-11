defmodule Roc.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subject" do
    field :status, :boolean, default: false
    field :marks, :integer
    field :class, :string
    field :percentage, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:marks, :class, :percentage, :status])
    |> validate_required([:marks, :class, :percentage, :status])
  end
end
