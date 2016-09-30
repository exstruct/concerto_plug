defmodule Concerto.Plug.Mazurka do
  defmodule UnresolvableResourceError do
    defexception [:resource, :params]

    def message(%{resource: resource, params: params}) do
      "Could not resolve the resource #{inspect(resource)} with #{inspect(params)} params."
    end
  end

  defmacro __using__(opts) do
    quote do
      use Concerto.Plug, unquote([{:router_key, :mazurka_router},
                                  {:route_key, :mazurka_route} | opts])

      def resolve(%{resource: resource, params: params, input: input, opts: opts} = affordance, source, conn) do
        case resolve(resource, params) do
          {method, path_info} ->
            %{affordance |
              method: method,
              path: "/" <> (
                path_info
                |> Stream.map(&to_param/1)
                |> Enum.join("/")
              ),
              fragment: opts[:fragment],
              query: case URI.encode_query(input) do
                       "" -> nil
                       other -> other
                     end}
            |> Mazurka.Plug.update_affordance(conn)
          :error ->
            exception = Concerto.Plug.Mazurka.UnresolvableResourceError.exception(resource: resource, params: params)
            raise Plug.Conn.WrapperError, conn: conn, type: :error, reason: exception
        end
      end

      def resolve_resource(resource_name, _source, _conn) do
        resolve_module(resource_name)
      end

      def to_param(%{id: id}) do
        id
      end
      def to_param(value) do
        value
      end
      defoverridable [to_param: 1]
    end
  end
end
