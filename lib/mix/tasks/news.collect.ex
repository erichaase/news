defmodule Mix.Tasks.News.Collect do
  use Mix.Task

  @shortdoc "Populates database with data collected from an external resource"

  @moduledoc """
    Populates database with data collected from an external resource
  """

  def run(_args) do
    # start app so that we can access database
    Mix.Task.run "app.start"

    ids = HackerNews.new_story_ids
    Mix.shell.info inspect(ids)
  end
end


# TODO: namespace this and move it into its own file
defmodule HackerNews do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://hacker-news.firebaseio.com"
  plug Tesla.Middleware.JSON

  def new_story_ids do
    r = get("/v0/newstories.json")
    case r.status do
      200 -> r.body
      _   -> raise inspect %{status: r.status, body: r.body}
    end
  end
end
