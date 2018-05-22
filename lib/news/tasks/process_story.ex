defmodule News.ProcessStoryTask do
  @moduledoc """
    Task to get a story and store it in the database
  """

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
