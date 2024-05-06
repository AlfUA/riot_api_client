defmodule RiotApiClient do
  @moduledoc """
  Entrypoint to the application
  """

  alias RiotApiClient.Geo
  alias RiotApiClient.Monitor
  alias RiotApiClient.Api.{Match, Summoner}

  @valid_subregions [
    "BR1",
    "EUN1",
    "EUW1",
    "JP1",
    "KR",
    "LA1",
    "LA2",
    "NA1",
    "OC1",
    "PH2",
    "RU",
    "SG2",
    "TH2",
    "TR1",
    "TW2",
    "VN2"
  ]

  @spec recent_summoners(String.t(), String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  def recent_summoners(summoner_name, subregion) do
    with {_, true} <- {:validation, valid_arguments?(summoner_name, subregion)},
         {_, {:ok, %{"puuid" => puuid}}} <-
           {:summoner, Summoner.get_by_name(summoner_name, subregion)},
         {_, {:ok, region}} <- {:region, Geo.subregion_to_region(subregion)},
         {_, {:ok, match_ids}} <- {:match_ids, Match.get_recent(puuid, region)} do
      participants_id_to_name =
        Match.multi_info(match_ids, region)
        |> Enum.flat_map(fn match -> match["info"]["participants"] end)
        |> Map.new(fn participant -> {participant["puuid"], participant["summonerName"]} end)
        |> Map.delete(puuid)

      Enum.each(participants_id_to_name, fn {id, name} ->
        Monitor.start(id, name, region)
      end)

      Map.values(participants_id_to_name)
    end
  end

  defp valid_arguments?(summoner_name, region)
       when is_binary(summoner_name) and region in @valid_subregions,
       do: true

  defp valid_arguments?(_, _), do: false
end
