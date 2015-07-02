defmodule EtsRegistry.Recovery do
  use GenServer
  use EtsRegistry.Common
  use EtsRegistry.Transfer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    try do
      EtsRegistry.Server.heir_recovery()
    catch
      :exit, reason -> {:ok, [] }
    else
      _ -> {:ok, [] }
    end
  end

  @spec register(String.t) :: :ok | {:error, :not_found}
  def register(table) do
    GenServer.call(__MODULE__, {:register, table})
  end

  def unstash() do
    GenServer.call(__MODULE__, :unstash)
  end

  def handle_call({:register, name}, _, state) do
    {:reply, EtsRegistry.Server.create(name), state}
  end

  def handle_call(:unstash, {new_owner, _reference}, state) do
    # Check that new_owner pid - under the same Supervisor
    if (Process.info(self())[:links] == Process.info(new_owner)[:links]) do
      Enum.each(state, &(:ets.give_away(&1, new_owner, Process.info(self())[:links])))
      {:reply, :ok, []}
    else
      {:reply, {:error, :not_permitted}, state}
    end
  end
end
