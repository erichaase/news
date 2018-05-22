defmodule Mix.Tasks.News.Collect do
  use Mix.Task

  @shortdoc "Populates database with data collected from an external resource"

  @moduledoc """
    Populates database with data collected from an external resource
  """

  def run(_args) do
    # start app so that we can access database
    Mix.Task.run "app.start"

    News.HackerNewsClient.get_new_story_ids
    # |> Enum.slice(0, 1)
    |> Enum.map(&start_task/1)
    |> Enum.each(&Task.await/1)
  end

  defp start_task(story_id) do
    # TODO: avoid parent crashing when child crashes
    Task.async(Mix.Tasks.News.Collect, :process_story, [story_id])
  end

  # TODO: move this into its own module/file
  def process_story(id) do
    if post = News.HackerNewsClient.get_story(id) do
      post |> build_post |> upsert_post
    end
  end

  defp build_post(story) do
    %News.Post{
      id_external: story["id"],
      url: story["url"],
      title: story["title"],
      n_points: story["score"],
      n_comments: story["descendants"],
      published_at: to_datetime(story["time"])
    }
  end

  defp to_datetime(unix_time) do
    case DateTime.from_unix(unix_time) do
      {:ok, datetime} -> datetime
      _               -> nil
    end
  end

  defp upsert_post(post) do
    case News.Repo.insert(post, on_conflict: :replace_all, conflict_target: :id_external) do
      {:ok, p} -> Mix.shell.info(inspect p)
      # TODO: add notifications for these errors
      {:error, cs} -> Mix.shell.error(inspect cs, pretty: true)
    end
  end
end
