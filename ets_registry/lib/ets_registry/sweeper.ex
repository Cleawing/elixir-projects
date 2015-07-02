defmodule EtsRegistry.Sweeper do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_info({:'ETS-TRANSFER', tab, _, _}, state) do
    # Just exit and linked ETS-table died, but Sweeper will be restarted by Supervisor
    exit(:normal)
  end

  use EtsRegistry.Common
end
