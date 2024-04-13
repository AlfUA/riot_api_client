defmodule RiotApiClient.Api.SummonerTest do
  use ExUnit.Case, async: true

  alias RiotApiClient.Api.Summoner

  describe "by_name/2" do
    test "when summoner name exists" do
      response = response_with("priv/test/summoners-by-name-Allie.json")

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 200, body: response}}
      end)

      {:ok, body} = Summoner.get_by_name("Allie", "NA1")
      assert response == body
    end

    test "when summoner name is not found" do
      message = "Data not found - summoner not found"

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 404, body: %{"status" => %{"message" => message}}}}
      end)

      {:error, reason} = Summoner.get_by_name("NotFound", "NA1")
      assert message == reason
    end

    test "when rate limit reached" do
      message = "Rate limit exceeded"

      Mimic.expect(Req, :get, fn _, _ ->
        {:ok, %Req.Response{status: 429, body: %{"status" => %{"message" => message}}}}
      end)

      {:error, reason} = Summoner.get_by_name("Allie", "NA1")
      assert message == reason
    end
  end

  defp response_with(file_name) do
    file_name
    |> File.read!()
    |> Jason.decode!()
  end
end
