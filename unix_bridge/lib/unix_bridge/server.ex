defmodule UnixBridge.Server do
  use GenServer
  require Logger

  def start_link(registry, opts \\ []) do
    GenServer.start_link(__MODULE__, registry, opts)
  end

  @spec init(:ets.tab) :: {:ok, UnixBridge.Data.State.t}
  def init(registry) do
    # TODO. Enumerate registry and restore Socat ports
    {:ok, %{registry: registry}}
  end

  @callback handle_call(UnixBridge.Data.add_call, pid, UnixBridge.Data.State.t) :: UnixBridge.Data.ok_reply | UnixBridge.Data.error_reply
  def handle_call({:add, name, config}, _from, state) do
    socat_port = %UnixBridge.Data.SocatPort{config: config}
    case :ets.insert_new(state.registry, {name, socat_port} ) do
      true -> {:reply, {:ok, socat_port}, state}
      false -> {:reply, {:error, ""}, state}
    end
  end

  @callback handle_call(UnixBridge.Data.update_call, pid, UnixBridge.Data.State.t) :: UnixBridge.Data.ok_reply | UnixBridge.Data.not_found_reply | UnixBridge.Data.error_reply
  def handle_call({:update, _name, _config}, _, _state) do

  end

  @callback handle_call({:get, atom}, pid, UnixBridge.Data.State.t) :: UnixBridge.Data.ok_reply | UnixBridge.Data.not_found_reply
  def handle_call({:get, name}, _, state) do
    case :ets.lookup(state.registry, name) do
      [{ ^name, socat_port }] -> {:reply, {:ok, socat_port}, state}
      [] -> { :reply, {:error, :not_found}, state}
    end
  end

  @callback handle_call(UnixBridge.Data.remove_call, pid, UnixBridge.Data.State.t) :: UnixBridge.Data.ok_reply | UnixBridge.Data.not_found_reply
  def handle_call({:remove, name}, _, state) do
    case :ets.lookup(state.registry, name) do
      [{ ^name, socat_port }] ->
        :ets.delete(state.registry, name)
        {:reply, {:ok, socat_port}, state}
      [] -> { :reply, {:error, :not_found}, state}
    end
  end

  # defp process_call{:get, name}, state) do
  #   case :ets.lookup(state.registry, name) do
  #     [{ ^name, socat_port }] -> {:reply, {:ok, socat_port}, state}
  #     [] -> { :reply, {:error, :not_found}, state}
  #   end
  # end

end
