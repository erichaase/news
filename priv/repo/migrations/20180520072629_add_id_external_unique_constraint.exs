defmodule News.Repo.Migrations.AddIdExternalUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:posts, [:id_external])
  end
end
