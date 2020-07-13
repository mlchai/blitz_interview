defmodule MatchTask do
  use Task
  require Logger

  @interval 60_000
  @run_amount 5

  def start_link(region, summoner_id, past_matches) do
    Task.start_link(__MODULE__, :loop, [region, summoner_id, past_matches, @run_amount])
  end

  def loop(region, summoner_id, past_matches, times) do
    matches = LeagueClient.find_summoner_matches(region, summoner_id)
    # this will print the last 5 matches on first run since we don't have
    # anything recorded for the past_matches
    Logger.info("Match diff for #{summoner_id}: #{inspect(matches -- past_matches)}")

    Process.send_after(self(), :nothing, @interval)
    receive do
      :nothing ->
        if times > 1 do
          loop(region, summoner_id, matches, times - 1)
        end
    end

  end

end
