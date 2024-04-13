import Config

config :riot_api_client,
  base_url_fragment: ".api.riotgames.com/lol/",
  check_every_seconds: 60,
  stop_monitor_after_seconds: 3_600,
  api_token: System.get_env("RG_API")

import_config "#{Mix.env()}.exs"
