defmodule UnixBridge do
  use Application

  @unix_bridge_server UnixBridge.Server

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    registry = :ets.new(:unix_bridge_registry, [:public, read_concurrency: true])

    children = [
      # Define workers and child supervisors to be supervised
      worker(UnixBridge.Server, [registry, [name: @unix_bridge_server]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UnixBridge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec add(atom, UnixBridge.Data.Config.t) :: UnixBridge.Data.ok | UnixBridge.Data.error
  def add(name, config) do
    GenServer.call(@unix_bridge_server, { :add, name, config } )
  end

  @spec update(atom, UnixBridge.Data.Config.t) :: UnixBridge.Data.ok | UnixBridge.Data.not_found | UnixBridge.Data.error
  def update(name, config) do
    GenServer.call(@unix_bridge_server, { :update, name, config } )
  end

  @spec get(atom) :: UnixBridge.Data.ok | UnixBridge.Data.not_found
  def get(name) do
    GenServer.call(@unix_bridge_server, { :get, name } )
  end

  @spec remove(atom) :: UnixBridge.Data.ok | UnixBridge.Data.not_found
  def remove(name) do
    GenServer.call(@unix_bridge_server, { :remove, name } )
  end
end
