defmodule EtsRegistry.Client do
  defmacro __using__(_) do
    quote do
      @spec create(String.t) :: {:ok, String.t} | {:error, :not_found}
      def create(name) when is_binary(name) do
        EtsRegistry.Recovery.register(name)
      end

      @spec drop(String.t) :: {:ok, String.t} | {:error, :not_found}
      def drop(name) when is_binary(name) do
        EtsRegistry.Server.drop(name)
      end

      @spec add(String.t, atom, term) :: {:ok, atom, term} | {:error, :not_found} | {:error, :already_exist}
      def add(name, key, value) do
        EtsRegistry.Server.add(name, key, value)
      end

      @spec update(String.t, atom, term) :: {:ok, atom, term} | {:error, :not_found}
      def update(name, key, value) do
        EtsRegistry.Server.update(name, key, value)
      end

      @spec get(String.t, atom) :: {:ok, atom, term} | {:error, :not_found}
      def get(name, key) do
        EtsRegistry.Server.get(name, key)
      end

      @spec remove(String.t, atom) :: {:ok, atom, term} | {:error, :not_found}
      def remove(name, key) do
        EtsRegistry.Server.remove(name, key)
      end
    end
  end
end
