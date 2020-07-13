defmodule LeagueClient do
  require Logger

  @regions %{
    "BR1" =>	"br1.api.riotgames.com",
    "EUN1" =>	"eun1.api.riotgames.com",
    "EUW1" =>	"euw1.api.riotgames.com",
    "JP1" =>	"jp1.api.riotgames.com",
    "KR" =>	"kr.api.riotgames.com",
    "LA1" =>	"la1.api.riotgames.com",
    "LA2" =>	"la2.api.riotgames.com",
    "NA1" =>	"na1.api.riotgames.com",
    "OC1" =>	"oc1.api.riotgames.com",
    "TR1" =>	"tr1.api.riotgames.com",
    "RU" =>	"ru.api.riotgames.com",
    "AMERICAS" =>	"americas.api.riotgames.com",
    "ASIA" =>	"asia.api.riotgames.com",
    "EUROPE" =>	"europe.api.riotgames.com"
  }

  def find_players_from_match(region, match_id) do
    request(region, "/lol/match/v4/matches/#{match_id}", fn json ->
      player_maps = Map.get(json, "participantIdentities")
      Enum.map(player_maps, &(Map.get(&1, "player"))) |> Enum.map(&(Map.get(&1, "accountId")))
    end)
  end

  def find_summoner_matches(region, summoner_id, limit \\ 5) do
    request(region, "/lol/match/v4/matchlists/by-account/#{summoner_id}?endIndex=#{limit}", fn json ->
      Map.get(json, "matches")
    end)
  end

  def find_summoner_id(region, name) do
    request(region, "/lol/summoner/v4/summoners/by-name/#{name}", fn json ->
      Map.get(json, "accountId")
    end)
  end

  def request(region, path, func) do
    case :httpc.request(:get, {to_charlist("https://#{Map.get(@regions, region)}#{path}"), [{'X-Riot-Token', to_charlist(Application.fetch_env!(:blitz, :riot_key))}]}, [], []) do
      {:ok, {{_, status, _}, _, body}} ->
        Logger.info("#{path}: #{status}")
        cond do
          # only handling rate limit here, let's just return an empty list
          # and let this job fail while logging the error
          status > 400 ->
            Logger.warn("Rate limit, returning empty")
            []
          true ->
            body_string = to_string(body)
            json = Jason.decode!(body_string)
            func.(json)
        end

      {:error, msg} ->
        Logger.error("Error: #{inspect(msg)}")
    end
  end

end
