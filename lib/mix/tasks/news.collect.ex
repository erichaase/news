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
    story = HackerNews.get_story(id)
    Mix.shell.info inspect story
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
