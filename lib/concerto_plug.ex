defmodule Concerto.Plug do
  defmodule NotFoundError do
    defexception [:method, :path_info]

    def message(%{method: method, path_info: path_info}) do
      "#{method} /#{Enum.join(path_info, "/")} not found"
    end

    defimpl Plug.Exception do
      def status(_) do
        404
      end
    end
  end

  defmacro __using__(opts) do
    router_key = opts[:router_key] || :concerto_router
    route_key  = opts[:route_key] || :concert_route
    plug_init = Keyword.get(opts, :plug_init, true)

    quote do
      unquote(if plug_init do
        quote do
          @before_compile unquote(__MODULE__)
          use Plug.Builder
        end
      end)

      @doc false
      def match(%{private: %{unquote(route_key) => _}} = conn, _opts) do
        conn
        |> Plug.Conn.put_private(unquote(router_key), __MODULE__)
      end
      def match(%Plug.Conn{method: method, path_info: path, private: private} = conn, _opts) do
        case match(method, Enum.map(path, &URI.decode/1)) do
          {module, params} ->
            conn
            |> Map.merge(%{
              params: params,
              private: Map.merge(private, %{
                unquote(route_key) => module,
                unquote(router_key) => __MODULE__
              })
            })
          nil ->
            exception = Concerto.Plug.NotFoundError.exception(method: method, path_info: path)
            raise Plug.Conn.WrapperError, conn: conn, kind: :error, reason: exception, stack: []
        end
      end

      @doc false
      def dispatch(%Plug.Conn{private: %{unquote(route_key) => route}} = conn, _opts) do
        route.call(conn, [])
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      if !Enum.member?(@plugs, {:match, [], true}) do
        require Plug.Builder
        Plug.Builder.plug :match
      end
      if !Enum.member?(@plugs, {:dispatch, [], true}) do
        require Plug.Builder
        Plug.Builder.plug :dispatch
      end
    end
  end
end
