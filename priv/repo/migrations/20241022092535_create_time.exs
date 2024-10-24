defmodule Roc.Repo.Migrations.CreateTime do
  use Ecto.Migration

  def change do

    alter table(:users) do
      add :time_zone, :string
      add :time_format, :string
      add :date_format, :string

  end
 end
end
