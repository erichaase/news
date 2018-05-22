defmodule News.HackerNews do
  @moduledoc """
    Client for Hacker News API
  """

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
      # TODO: return {:ok, stories} tuple instead
      _ -> raise inspect %{status: r.status, body: r.body}
    end
  end
end
