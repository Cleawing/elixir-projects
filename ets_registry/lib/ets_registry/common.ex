defmodule EtsRegistry.Common do
  defmacro __using__(_) do
    quote do
      @spec state() :: term
      def state() do
        GenServer.call(__MODULE__, :state)
      end

      def handle_call(:state, _, state) do
        {:reply, state, state}
      end
    end
  end
end
