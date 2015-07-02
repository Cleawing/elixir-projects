defmodule EtsRegistry.Sweeper do
  use GenServer
  use EtsRegistry.Common

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def destroy(tab) do
    :ets.setopts(tab, {:heir, :none})
    :ets.give_away(tab, Process.whereis(__MODULE__), nil)
  end

  def handle_info({:'ETS-TRANSFER', tab, _, _}, state) do
    poison = spawn(EtsRegistry.Sweeper, :poison_pill, [])
    :ets.give_away(tab, poison, nil)
    {:noreply, state}
  end

  def poison_pill do
    receive do
      {:'ETS-TRANSFER', _, _, _} -> :ok
    end
  end
end
