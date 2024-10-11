defmodule Roc.Repo.Migrations.CreateSubject do
  use Ecto.Migration

  def change do
    create table(:subject) do
      add :marks, :integer
      add :class, :string
      add :percentage, :integer
      add :status, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
