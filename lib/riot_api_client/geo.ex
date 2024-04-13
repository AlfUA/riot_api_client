defmodule RiotApiClient.Geo do
  @moduledoc """
  Subregion to region matching logic based on following:
  https://leagueoflegends.fandom.com/wiki/Servers
  """

  @spec subregion_to_region(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def subregion_to_region(subregion) when subregion in ["BR1", "LA1", "LA2", "NA1"],
    do: {:ok, "americas"}

  def subregion_to_region(subregion) when subregion in ["EUN1", "EUW1", "RU", "TR1"],
    do: {:ok, "europe"}

  def subregion_to_region(subregion) when subregion in ["JP1", "KR"], do: {:ok, "asia"}

  def subregion_to_region(subregion) when subregion in ["OC1", "PH2", "SG2", "TH2", "TW2", "VN2"],
    do: {:ok, "sea"}

  def subregion_to_region(_), do: {:error, "Unknown Region"}
end
