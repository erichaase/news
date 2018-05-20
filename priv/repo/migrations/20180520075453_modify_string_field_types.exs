defmodule News.Repo.Migrations.ModifyStringFieldTypes do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :title, :text
      modify :url, :text
    end
  end
end
