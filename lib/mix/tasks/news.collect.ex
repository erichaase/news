defmodule Mix.Tasks.News.Collect do
  use Mix.Task
  use Tesla

  @shortdoc "Populates database with data collected from an external resource"

  @moduledoc """
    Populates database with data collected from an external resource
  """

  def run(_args) do
    # start app so that we can access database
    Mix.Task.run "app.start"

    {:ok, ids} = HackerNews.new_story_ids
    Mix.shell.info inspect(ids)
  end
end


# TODO: move this into its own file
defmodule HackerNews do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://hacker-news.firebaseio.com"
  plug Tesla.Middleware.JSON

  def new_story_ids do
    r = get("/v0/newstories.json")
    case r.status do
      200 -> {:ok, r.body}
      _   -> {:error, %{status: r.status, body: r.body}}
    end
  end
end
