defmodule UnixBridge.Data do
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

  defmodule State do
    defstruct registry: nil
    @type t :: %State{registry: map}
  end

  @type ok :: {:ok, SocatPort.t}
  @type not_found :: {:error, :not_found}
  @type error :: {:error, String.t}

  @type ok_reply :: {:reply, ok, State.t}
  @type not_found_reply :: {:reply, not_found, State.t}
  @type error_reply :: {:reply, error, State.t}

  @type add_call :: {:add, atom, Config.t}
  @type update_call :: {:update, atom, Config.t}
  @type get_call :: {:get, atom}
  @type remove_call :: {:remove, atom}
end
