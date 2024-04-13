defmodule RiotApiClientTest do
  use ExUnit.Case
  use Mimic

  describe "recent_summoners/2" do
    test "validation testing" do
      assert {:validation, false} == RiotApiClient.recent_summoners("user", "invalid subregion")
      assert {:validation, false} == RiotApiClient.recent_summoners(123, "invalid subregion")
      assert {:validation, false} == RiotApiClient.recent_summoners(["user"], "invalid subregion")
    end

    test "when input is valid and summoner exists" do
      Req
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/summoners-by-name-Allie.json")}}
      end)
      |> expect(:get, fn _, _ ->
        puuid = "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg"

        {:ok,
         %Req.Response{
           status: 200,
           body: response_with("priv/test/matches-by_puuid-#{puuid}.json")
         }}
      end)
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/matches-NA1_4053583588.json")}}
      end)
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/matches-NA1_4053609198.json")}}
      end)
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/matches-NA1_4053730999.json")}}
      end)
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/matches-NA1_4053745887.json")}}
      end)
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/matches-NA1_4053830000.json")}}
      end)

      summoners = RiotApiClient.recent_summoners("Allie", "NA1")
      assert 45 == length(summoners)

      assert %{active: 45, specs: 45, supervisors: 0, workers: 45} ==
               DynamicSupervisor.count_children(RiotApiClient.UserMonitoringDynamicSupervisor)

      clean_on_exit()
    end

    test "responds with error tuple when summoners api responds with error" do
      Req
      |> expect(:get, fn _, _ ->
        {:ok, %Req.Response{status: 403, body: %{"status" => %{"message" => "Forbidden"}}}}
      end)

      assert {:summoner, {:error, "Forbidden"}} == RiotApiClient.recent_summoners("Allie", "NA1")
    end

    test "responds with error tuple when match api responds with error on get_recent/2" do
      Req
      |> expect(:get, fn _, _ ->
        {:ok,
         %Req.Response{status: 200, body: response_with("priv/test/summoners-by-name-Allie.json")}}
      end)
      |> expect(:get, fn _, _ ->
        {:ok, %Req.Response{status: 403, body: %{"status" => %{"message" => "Forbidden"}}}}
      end)

      assert {:match_ids, {:error, "Forbidden"}} == RiotApiClient.recent_summoners("Allie", "NA1")
    end
  end

  defp response_with(file_name) do
    file_name
    |> File.read!()
    |> Jason.decode!()
  end

  defp clean_on_exit do
    RiotApiClient.UserMonitoringDynamicSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
    |> Enum.each(fn pid ->
      DynamicSupervisor.terminate_child(RiotApiClient.UserMonitoringDynamicSupervisor, pid)
    end)
  end
end
