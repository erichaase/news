defmodule News.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :clicked_at, :utc_datetime
    field :id_external, :integer
    field :n_comments, :integer
    field :n_points, :integer
    field :published_at, :utc_datetime
    field :read_at, :utc_datetime
    field :title, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:id_external, :url, :title, :n_points, :n_comments, :published_at, :read_at, :clicked_at])
    # |> validate_required([:id_external, :url, :title, :n_points, :n_comments, :published_at, :read_at, :clicked_at])
    |> validate_required([:id_external])
    |> unique_constraint(:id_external)
  end
end
