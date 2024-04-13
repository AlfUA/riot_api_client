defmodule RiotApiClient.Monitor do
  @moduledoc """
  GenServer that implements monitoring logic.
  Each player is being monitored by its own process and works under dynamic supervisor
  """

  use GenServer
  alias RiotApiClient.Api.Match

  @spec start(String.t(), String.t(), String.t()) :: :ok | {:error, :user_already_monitored}
  def start(puuid, name, region) do
    check_every_seconds = Application.fetch_env!(:riot_api_client, :check_every_seconds)

    stop_monitor_after_seconds =
      Application.fetch_env!(:riot_api_client, :stop_monitor_after_seconds)

    case DynamicSupervisor.start_child(
           RiotApiClient.UserMonitoringDynamicSupervisor,
           {__MODULE__,
            %{
              puuid: puuid,
              name: via_tuple(name, region),
              display_name: name,
              region: region,
              check_every: :timer.seconds(check_every_seconds),
              stop_after: DateTime.add(DateTime.utc_now(), stop_monitor_after_seconds),
              last_match_id: nil
            }}
         ) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :user_already_monitored}
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts,
      name: opts |> Map.fetch!(:puuid) |> via_tuple(Map.fetch!(opts, :region))
    )
  end

  def init(state) do
    {:ok, state, {:continue, :init_match}}
  end

  def handle_continue(:init_match, state) do
    Process.send_after(self(), :update_summoner_data, state.check_every)

    case Match.get_recent(state.puuid, state.region, 1) do
      {:ok, [last_match_id]} ->
        {:noreply, Map.put(state, :last_match_id, last_match_id)}

      {:error, _reason} ->
        {:noreply, state}
    end
  end

  def handle_info(:update_summoner_data, state) do
    with :lt <- DateTime.compare(DateTime.utc_now(), state.stop_after),
         {:ok, [last_match_id]} when last_match_id != state.last_match_id <-
           Match.get_recent(state.puuid, state.region, 1) do
      IO.puts(
        "Summoner #{state.display_name} completed match #{last_match_id} in region #{state.region}"
      )

      Process.send_after(self(), :update_summoner_data, state.check_every)
      {:noreply, Map.put(state, :last_match_id, last_match_id)}
    else
      value when value in [:gt, :eq] ->
        Registry.unregister(RiotApiClient.SummonersRegistry, via_tuple(state.puuid, state.region))
        DynamicSupervisor.terminate_child(RiotApiClient.UserMonitoringDynamicSupervisor, self())
        {:stop, :completed, state}

      _ ->
        Process.send_after(self(), :update_summoner_data, state.check_every)
        {:noreply, state}
    end
  end

  defp via_tuple(id, region) do
    {:via, Registry, {RiotApiClient.SummonersRegistry, id <> region}}
  end
end
