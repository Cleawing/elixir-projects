defmodule EtsRegistry.Client do
  defmacro __using__(_) do
    quote location: :keep do
      def create(name) do
        EtsRegistry.Recovery.register(name)
      end
    end
  end
end
