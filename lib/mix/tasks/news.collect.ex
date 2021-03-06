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
    |> validate_response
    # |> Enum.slice(0, 1)
    |> Enum.map(&start_task/1)
    |> Enum.each(&Task.await/1)
  end

  defp validate_response({:ok, ids}) when is_list(ids), do: ids
  defp start_task(story_id), do: Task.async(News.ProcessStoryTask, :process_story, [story_id])
  # TODO: spawn task under a supervisor so that child crashing doesn't crash parent process
end
