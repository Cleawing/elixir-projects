defmodule EtsRegistry.Common do
  defmacro __using__(_) do
    quote do
      @spec pid() :: pid
      def pid() do
        GenServer.call(__MODULE__, :pid)
      end

      @spec state() :: term
      def state() do
        GenServer.call(__MODULE__, :state)
      end

      def handle_call(:pid, _, state) do
        {:reply, self(), state}
      end

      def handle_call(:state, _, state) do
        {:reply, state, state}
      end
    end
  end
end
