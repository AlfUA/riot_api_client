defmodule RiotApiClient.MonitorTest do
  use ExUnit.Case

  alias RiotApiClient.Monitor

  setup do
    on_exit(fn ->
      RiotApiClient.UserMonitoringDynamicSupervisor
      |> DynamicSupervisor.which_children()
      |> Enum.map(fn {_, pid, _, _} -> pid end)
      |> Enum.each(fn pid ->
        DynamicSupervisor.terminate_child(RiotApiClient.UserMonitoringDynamicSupervisor, pid)
      end)
    end)
  end

  test "creates a unique worker for user in region" do
    puuid = "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg"
    name = "Allie"
    region = "americas"

    assert %{active: 0, specs: 0, supervisors: 0, workers: 0} ==
             DynamicSupervisor.count_children(RiotApiClient.UserMonitoringDynamicSupervisor)

    assert :ok == Monitor.start(puuid, name, region)

    assert %{active: 1, specs: 1, supervisors: 0, workers: 1} ==
             DynamicSupervisor.count_children(RiotApiClient.UserMonitoringDynamicSupervisor)

    assert {:error, :user_already_monitored} == Monitor.start(puuid, name, region)
    DynamicSupervisor.terminate_child(RiotApiClient.UserMonitoringDynamicSupervisor, self())
  end

  test "it's possible to start monitoring in other region" do
    puuid = "1V2eCFBB_an5U8QVaM4bvl7jOSDbupDJdb2ggsujQGnmWmRMXosHIIt-eV7qEjUKYjG302tfqhxHwg"
    name = "Allie"
    region = "americas"
    another_region = "europe"

    assert :ok == Monitor.start(puuid, name, region)

    assert %{active: 1, specs: 1, supervisors: 0, workers: 1} ==
             DynamicSupervisor.count_children(RiotApiClient.UserMonitoringDynamicSupervisor)

    assert :ok == Monitor.start(puuid, name, another_region)

    assert %{active: 2, specs: 2, supervisors: 0, workers: 2} ==
             DynamicSupervisor.count_children(RiotApiClient.UserMonitoringDynamicSupervisor)
  end
end
