defmodule EtsRegistry.Client do
  defmacro __using__(_) do
    quote do
      @spec create(String.t) :: :ok | {:error, :not_found}
      def create(name) when is_binary(name) do
        EtsRegistry.Recovery.register(name)
      end

      @spec drop(String.t) :: :ok | {:error, :not_found}
      def drop(name) when is_binary(name) do
        EtsRegistry.Server.drop(name)
      end
    end
  end
end
