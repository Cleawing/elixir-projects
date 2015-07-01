defmodule UnixBridge.Server do
  use GenServer
  require Logger

  defmodule State do
    defstruct registry: nil
    @type t :: %State{registry: map}
  end

  def start_link(registry, opts \\ []) do
    GenServer.start_link(__MODULE__, registry, opts)
  end

  @spec init(:ets.tab) :: {:ok, State.t}
  def init(registry) do
    # TODO. Enumerate registry and restore Socat ports
    {:ok, %{registry: registry}}
  end

  def handle_call({:add, name, config}, _from, state) do
    socat_port = %UnixBridge.SocatPort{config: config}
    case :ets.insert_new(state.registry, {name, socat_port} ) do
      true -> {:reply, {:ok, socat_port}, state}
      false -> {:reply, {:error, ""}, state}
    end
  end

  def handle_call({:update, _name, _config}, _, _state) do

  end

  def handle_call({:get, name}, _, state) do
    case :ets.lookup(state.registry, name) do
      [{ ^name, socat_port }] -> {:reply, {:ok, socat_port}, state}
      [] -> { :reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:remove, name}, _, state) do
    case :ets.lookup(state.registry, name) do
      [{ ^name, socat_port }] ->
        :ets.delete(state.registry, name)
        {:reply, {:ok, socat_port}, state}
      [] -> { :reply, {:error, :not_found}, state}
    end
  end

end
