defmodule News.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :id_external, :integer
      add :url, :string
      add :title, :string
      add :n_points, :integer
      add :n_comments, :integer
      add :published_at, :utc_datetime
      add :read_at, :utc_datetime
      add :clicked_at, :utc_datetime

      timestamps()
    end

  end
end
