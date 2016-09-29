defmodule Concerto.Plug.Mazurka do
  defmacro __using__(opts) do
    quote do
      use Concerto.Plug, unquote([{:router_key, :mazurka_router},
                                  {:route_key, :mazurka_route} | opts])

      def resolve(%{resource: resource, params: params, input: input, opts: opts} = affordance, source, conn) do
        case resolve(resource, params) do
          {method, path} ->
            %{affordance |
              method: method,
              path: Concerto.Plug.Mazurka.__format_path__(path),
              fragment: opts[:fragment],
              query: case URI.encode_query(input) do
                       "" -> nil
                       other -> other
                     end}
            |> Mazurka.Plug.update_affordance(conn)
          nil ->
            nil
        end
      end

      def resolve_resource(resource_name, _source, _conn) do
        resolve_module(resource_name)
      end
    end
  end

  def __format_path__([]) do
    ""
  end
  def __format_path__([a]) do
    "/" <> a
  end
  def __format_path__([a, b]) do
    "/" <> a <> "/" <> b
  end
  def __format_path__([a, b, c]) do
    "/" <> a <> "/" <> b <> "/" <> c
  end
  def __format_path__(path) do
    "/" <> Enum.join(path, "/")
  end
end
