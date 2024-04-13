defmodule RiotApiClient.Api.Summoner do
  @moduledoc """
  Module for interaction with the Riot Games API for summoners:
  https://developer.riotgames.com/apis#summoner-v4
  NOTE: Endpoint which gets summoner by name will be removed on April 22, 2024
  """
  @spec get_by_name(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def get_by_name(summoner_name, subregion) do
    api_token = Application.fetch_env!(:riot_api_client, :api_token)
    base_url_fragment = Application.fetch_env!(:riot_api_client, :base_url_fragment)
    base_url = "https://" <> String.downcase(subregion) <> base_url_fragment

    [base_url: base_url]
    |> Req.new()
    |> Req.Request.put_header("X-Riot-Token", api_token)
    |> Req.get(url: "summoner/v4/summoners/by-name/" <> summoner_name)
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{body: body}} ->
        {:error, body["status"]["message"]}
    end
  end
end
