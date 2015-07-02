defmodule EtsRegistry.Server do
  use GenServer
  use EtsRegistry.Common
  use EtsRegistry.Transfer

  @table_prefix __MODULE__

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    EtsRegistry.Recovery.unstash()
    {:ok, []}
  end

  @spec create(String.t) :: :ok | {:error, :not_found}
  def create(name) do
    GenServer.call(__MODULE__, {:create, name})
  end

  def drop(name) do
    GenServer.call(__MODULE__, {:drop, name})
  end

  def add(name, key, value) do
    GenServer.call(__MODULE__, {:add, name, key, value})
  end

  def update(name, key, value) do
    GenServer.call(__MODULE__, {:update, name, key, value})
  end

  def get(name, key) do
    GenServer.call(__MODULE__, {:get, name, key})
  end

  def remove(name, key) do
    GenServer.call(__MODULE__, {:remove, name, key})
  end

  def heir_recovery() do
      GenServer.call(__MODULE__, :heir_recovery)
  end

  def handle_call({:create, name}, {recover_to, _reference}, state) do
    case lookup_table(name) do
      {:error, :not_found} -> {:reply, {:ok, name}, table(name) |> create_table(state, recover_to)}
      {:ok, tab} -> {:reply, {:error, :already_created}, state}
    end
  end

  def handle_call({:drop, name}, _, state) do
    case lookup_table(name) do
      res = {:error, :not_found} -> {:reply, res, state}
      {:ok, tab} ->
        EtsRegistry.Sweeper.destroy(tab)
        {:reply, {:ok, name}, state -- [tab]}
    end
  end

  def handle_call({:add, name, key, value}, _, state) do
    case lookup_table(name) do
      res = {:error, :not_found} -> {:reply, res, state}
      {:ok, tab} ->
        case :ets.insert_new(tab, {key, value}) do
          true -> {:reply, {:ok, key, value}, state}
          false -> {:reply, {:error, :already_exist}, state}
        end
    end
  end

  def handle_call({:update, name, key, value}, _, state) do
    case lookup_table(name) do
      res = {:error, :not_found} -> {:reply, res, state}
      {:ok, tab} ->
        if :ets.member(tab, key) do
          :ets.insert(tab, {key, value})
          {:reply, {:ok, key, value}, state}
        else
          {:reply, {:error, :not_found}, state}
        end
    end
  end

  def handle_call({:get, name, key}, _, state) do
    case lookup_table(name) do
      res = {:error, :not_found} -> {:reply, res, state}
      {:ok, tab} ->
        case :ets.lookup(tab, key) do
          [{_, value}] -> {:reply, {:ok, key, value}, state}
          [] -> {:reply, {:error, :not_found}, state}
        end
    end
  end

  def handle_call({:remove, name, key}, _, state) do
    case lookup_table(name) do
      res = {:error, :not_found} -> {:reply, res, state}
      {:ok, tab} ->
        case :ets.lookup(tab, key) do
          [{_, value}] ->
            :ets.delete(tab, key)
            {:reply, {:ok, key, value}, state}
          [] -> {:reply, {:error, :not_found}, state}
        end
    end
  end

  def handle_call(:heir_recovery, {recover_to, _reference}, state) do
    # Ensure that we update heir for ETS-table under the same Supervisor
    if (Process.info(self())[:links] == Process.info(recover_to)[:links]) do
      Enum.each(state, &(:ets.setopts(&1, {:heir, recover_to, Process.info(self())[:links]})))
      {:reply, :ok, state}
    else
      {:reply, {:error, :not_permitted}, state}
    end
  end

  @spec create_table(atom, EtsRegistry.Data.state, pid) :: EtsRegistry.Data.state
  def create_table(tab, state, recover_to) do
    state ++ [:ets.new(tab, [:private, :named_table, {:heir, recover_to, Process.info(self())[:links]}])]
  end

  @spec table(String.t) :: atom
  def table(name) do
    String.to_atom("#{@table_prefix}.#{name}")
  end

  @spec lookup_table(String.t | atom) :: {:ok, :ets.tab} | {:error, :not_found}
  def lookup_table(name) do
    tab = case name do
      tab when is_binary(name) -> table(name)
      tab when is_atom(name) -> tab
    end
    if tab in :ets.all do
      {:ok, tab}
    else
      {:error, :not_found}
    end
  end
end
