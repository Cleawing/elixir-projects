defmodule UnixBridge do
  use Application

  @unix_bridge_server UnixBridge.Server

  defmodule Config do
    defstruct bypass_for: nil, check_uri: "/", unix_socket_path: nil, binding_ip: "127.0.0.1", binding_port: 0
    @type t :: %Config {
      bypass_for: String.t, # If bypass url provided and alive - bypass creating socat bridge
      check_uri: String.t, # Uri for checking
      unix_socket_path: String.t, # Unix socket path as source
      binding_ip: String.t, # Binding socat to this IP
      binding_port: integer # Binding socat to this port. 0 - choice random avaible port
    }
  end

  defmodule SocatPort do
    @derive [Access]
    defstruct config: nil, pid: nil, unix_socket_path: nil, binded_to: nil
    @type t :: %SocatPort{
      config: Config.t,
      pid: pid,
      unix_socket_path: String.t,
      binded_to: String.t
    }
  end

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

  @type ok :: {:ok, SocatPort.t}
  @type not_found :: {:error, :not_found}
  @type error :: {:error, String.t}

  @spec add(atom, Config.t) :: ok | error
  def add(name, config) do
    GenServer.call(@unix_bridge_server, { :add, name, config } )
  end

  @spec update(atom, Config.t) :: ok | not_found | error
  def update(name, config) do
    GenServer.call(@unix_bridge_server, { :update, name, config } )
  end

  @spec get(atom) :: ok | not_found
  def get(name) do
    GenServer.call(@unix_bridge_server, { :get, name } )
  end

  @spec remove(atom) :: ok | not_found
  def remove(name) do
    GenServer.call(@unix_bridge_server, { :remove, name } )
  end
end
