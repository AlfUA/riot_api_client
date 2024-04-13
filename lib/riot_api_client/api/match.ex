defmodule RiotApiClient.Api.Match do
  @moduledoc """
  Module for interaction with the Riot Games API for matches:
  https://developer.riotgames.com/apis#match-v5
  """
  @spec get_recent(String.t(), String.t(), non_neg_integer()) ::
          {:ok, [String.t()]} | {:error, String.t()}
  def get_recent(puuid, region, count \\ 5) do
    api_token = Application.fetch_env!(:riot_api_client, :api_token)
    base_url_fragment = Application.fetch_env!(:riot_api_client, :base_url_fragment)
    base_url = "https://" <> region <> base_url_fragment

    [base_url: base_url, params: [start: 0, count: count]]
    |> Req.new()
    |> Req.Request.put_header("X-Riot-Token", api_token)
    |> Req.get(url: "match/v5/matches/by-puuid/" <> puuid <> "/ids")
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{body: body}} -> {:error, body["status"]["message"]}
    end
  end

  @spec info(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def info(match_id, region) do
    api_token = Application.fetch_env!(:riot_api_client, :api_token)
    base_url_fragment = Application.fetch_env!(:riot_api_client, :base_url_fragment)
    base_url = "https://" <> region <> base_url_fragment

    [base_url: base_url]
    |> Req.new()
    |> Req.Request.put_header("X-Riot-Token", api_token)
    |> Req.get(url: "match/v5/matches/" <> match_id)
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{body: body}} -> {:error, body["status"]["message"]}
    end
  end

  @spec multi_match_info([String.t()], String.t()) :: {:ok, [map()]} | {:error, [String.t()]}
  def multi_match_info(match_ids, match_region) do
    match_ids
    |> Enum.map(fn match_id -> Task.async(fn -> info(match_id, match_region) end) end)
    |> Enum.reduce([], fn task, acc ->
      case Task.await(task) do
        {:ok, match} ->
          [match | acc]

        _error ->
          acc
      end
    end)
  end
end
