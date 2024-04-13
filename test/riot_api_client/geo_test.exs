defmodule RiotApiClient.GeoTest do
  use ExUnit.Case, async: true

  alias RiotApiClient.Geo

  test "proper matching for Europe region" do
    assert Geo.subregion_to_region("EUN1") == {:ok, "europe"}
    assert Geo.subregion_to_region("EUW1") == {:ok, "europe"}
    assert Geo.subregion_to_region("RU") == {:ok, "europe"}
    assert Geo.subregion_to_region("TR1") == {:ok, "europe"}
  end

  test "proper matching for Americas region" do
    assert Geo.subregion_to_region("BR1") == {:ok, "americas"}
    assert Geo.subregion_to_region("LA1") == {:ok, "americas"}
    assert Geo.subregion_to_region("LA2") == {:ok, "americas"}
    assert Geo.subregion_to_region("NA1") == {:ok, "americas"}
  end

  test "proper matching for Asia region" do
    assert Geo.subregion_to_region("JP1") == {:ok, "asia"}
    assert Geo.subregion_to_region("KR") == {:ok, "asia"}
  end

  test "proper matching for SEA region" do
    assert Geo.subregion_to_region("OC1") == {:ok, "sea"}
    assert Geo.subregion_to_region("PH2") == {:ok, "sea"}
    assert Geo.subregion_to_region("SG2") == {:ok, "sea"}
    assert Geo.subregion_to_region("TH2") == {:ok, "sea"}
    assert Geo.subregion_to_region("TW2") == {:ok, "sea"}
    assert Geo.subregion_to_region("VN2") == {:ok, "sea"}
  end

  test "returns error for unknown region" do
    assert Geo.subregion_to_region("Random Text") == {:error, "Unknown Region"}
  end
end
