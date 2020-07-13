import Config

config :blitz,
  region: (System.get_env("REGION") || "NA1"),
  riot_key: System.get_env("RIOT_KEY"),
  summoner_name: System.get_env("SUMMONER_NAME")
