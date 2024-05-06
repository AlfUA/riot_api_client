defmodule RiotApiClient.Api.MatchTest do
  use ExUnit.Case, async: true
  use Mimic

  alias RiotApiClient.Api.Match

  describe "recent/3" do
    test "with valid response" do
      puuid = "zbS8gpGwGtZ5h5PVanKyjxy4z8FltI9huyfGU1bZSUklWY_cGZQ1X_sCCMUinbXMeEeArskNOK4f3Q"

      response = response_with("priv/test/matches-by_puuid-#{puuid}.json")

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 200, body: response}}
      end)

      {:ok, body} = Match.get_recent(puuid, "americas")
      assert response == body
    end

    test "error response when token is expired" do
      puuid = "zbS8gpGwGtZ5h5PVanKyjxy4z8FltI9huyfGU1bZSUklWY_cGZQ1X_sCCMUinbXMeEeArskNOK4f3Q"
      message = "Forbidden"

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 403, body: %{"status" => %{"message" => message}}}}
      end)

      {:error, reason} = Match.get_recent(puuid, "americas")
      assert message == reason
    end
  end

  describe "info/2" do
    test "with valid response" do
      response = response_with("priv/test/matches-NA1_4053583588.json")

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 200, body: response}}
      end)

      {:ok, body} = Match.info("NA1_4053583588", "americas")
      assert response == body
    end

    test "error response when data doesn't exist" do
      message = "Data not found"

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 403, body: %{"status" => %{"message" => message}}}}
      end)

      {:error, reason} = Match.info("NA1_4053583588", "americas")
      assert message == reason
    end
  end

  describe "multi_info/2" do
    test "with valid response" do
      response = response_with("priv/test/matches-NA1_4053583588.json")

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 200, body: response}}
      end)

      [result] = Match.multi_info(["NA1_4053583588"], "americas")

      assert response == result
    end
  end

  defp response_with(file_name) do
    file_name
    |> File.read!()
    |> Jason.decode!()
  end
end
