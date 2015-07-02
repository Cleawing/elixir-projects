defmodule EtsRegistry.Transfer do
  defmacro __using__(_) do
    quote do
      def handle_info({:'ETS-TRANSFER', tab, _, links}, state) do
        # Ensure that we transfer ownership of ETS-table under the same Supervisor
        if (Process.info(self())[:links] == links) do
          {:noreply, state ++ [tab]}
        else
          # Delete table, because orphan
          :ets.setopts(tab, {:heir, :none})
          :ets.give_away(tab, EtsRegistry.Sweeper.pid(), nil)
          {:noreply, state}
        end
      end
    end
  end
end
