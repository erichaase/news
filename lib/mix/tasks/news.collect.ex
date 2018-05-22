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
    Task.async(News.ProcessStoryTask, :process_story, [story_id])
  end
end
