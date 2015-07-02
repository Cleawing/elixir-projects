defmodule EtsRegistry.Common do
  defmacro __using__(_) do
    quote location: :keep do
      @spec pid() :: pid
      def pid() do
        GenServer.call(__MODULE__, :pid)
      end

      def handle_call(:pid, _, state) do
        {:reply, self(), state}
      end
    end
  end
end
