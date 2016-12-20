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
              path: "/" <> Enum.join(path_info, "/"),
              fragment: opts[:fragment],
              query: case URI.encode_query(input) do
                       "" -> nil
                       other -> other
                     end}
            |> Mazurka.Plug.update_affordance(conn)
          nil ->
            %Mazurka.Affordance.Undefined{resource: resource,
                                          params: params,
                                          input: input,
                                          opts: opts,
                                          mediatype: affordance.mediatype}
          :error ->
            exception = Concerto.Plug.Mazurka.UnresolvableResourceError.exception(resource: resource, params: params)
            raise Plug.Conn.WrapperError, conn: conn, type: :error, reason: exception, stack: []
        end
      end

      def resolve_resource(resource_name, _source, _conn) do
        resolve_module(resource_name)
      end

      def format_params(params, _source, _conn) do
        Enum.reduce(params, params, fn({key, value}, acc) ->
          %{acc | key => to_param(value)}
        end)
      end

      def to_param(%{id: id}), do: id
      def to_param(%{"id" => id}), do: id
      def to_param(value), do: value
      defoverridable [to_param: 1]
    end
  end
end
