defmodule Blitz do
  require Logger
  @moduledoc """
  Documentation for `Blitz`.
  """

  @doc """
  Gets matches from a summoner and runs async tasks to list the match diffs of
  everyone in those matches
  """
  def find_recently_played_with_matches(region, summoner_name) do
    Logger.info("Starting with #{Application.fetch_env!(:blitz, :region)}")

    summoner_id = LeagueClient.find_summoner_id(region, summoner_name)
    Logger.info("Got ID for #{summoner_name}: #{summoner_id}")

    matches = LeagueClient.find_summoner_matches(region, summoner_id)
    Logger.info("Got matches: #{inspect(matches)}")

    match_id_list = Enum.map(matches, &(Map.get(&1, "gameId")))
    Logger.info("Got match ids: #{inspect(match_id_list)}")

    # get the list of lists of player ids, flatten it, then uniq it
    player_id_list = build_player_id_list(region, match_id_list, []) |> List.flatten |> Enum.uniq
    Logger.info("Got all players to monitor: #{inspect(player_id_list)}")

    start_tasks(region, player_id_list)

    :ok
  end

  def build_player_id_list(region, [], player_id_list) do
    player_id_list
  end

  def build_player_id_list(region, [ head | tail ], player_id_list) do
    build_player_id_list(region, tail, [ LeagueClient.find_players_from_match(region, head) | player_id_list ])
  end

  def start_tasks(region, []) do
    :nothing
  end

  def start_tasks(region, [ head | tail ]) do
    MatchTask.start_link(region, head, [])
    # add a small 5 second delay between tasks so we have less chance
    # of hitting rate limit
    :timer.sleep(5000)
    start_tasks(region, tail)
  end

end

Blitz.find_recently_played_with_matches(Application.fetch_env!(:blitz, :region), Application.fetch_env!(:blitz, :summoner_name))
