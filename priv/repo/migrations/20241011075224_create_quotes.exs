defmodule Roc.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :quote, :text
      add :author, :string
      add :source, :string

      timestamps(type: :utc_datetime)
    end
  end
end
