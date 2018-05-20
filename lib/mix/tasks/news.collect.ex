defmodule Mix.Tasks.News.Collect do
  use Mix.Task

  @shortdoc "Populates database with data collected from an external resource"

  @moduledoc """
    Populates database with data collected from an external resource
  """

  def run(_args) do
    # start app so that we can access database
    Mix.Task.run "app.start"

    HackerNews.get_new_story_ids
    # |> Enum.slice(0, 1)
    |> Enum.each(&process_story/1)
  end

  # TODO: run this asynchronous
  defp process_story(id) do
    if post = HackerNews.get_story(id) do
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
      {:ok, p} -> Mix.shell.info(inspect p, pretty: true)
      # TODO: add notifications for these errors
      {:error, cs} -> Mix.shell.error(inspect cs, pretty: true)
    end
  end
end


# TODO: namespace this and move it into its own file
defmodule HackerNews do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://hacker-news.firebaseio.com"
  plug Tesla.Middleware.JSON

  def get_new_story_ids do
    get("/v0/newstories.json")
    |> process_response
  end

  def get_story(id) do
    get("/v0/item/#{id}.json")
    |> process_response
  end

  defp process_response(r) do
    case r.status do
      200 -> r.body
      _   -> raise inspect %{status: r.status, body: r.body}
    end
  end
end
