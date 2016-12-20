defmodule ConcertoPlugTest do
  use ExUnit.Case
  use Plug.Test

  defmodule Router do
    use Concerto, [root: "#{__DIR__}/fixtures",
                   ext: ".ex",
                   module_prefix: ConcertoPlugTest.Resource]

    use Concerto.Plug.Mazurka
  end

  defmodule Resource.GET do
    use Mazurka.Resource
    use Mazurka.Plug

    mediatype Hyper do
      action do
        %{
          "Hello" => "Concerto",
          "bar" => link_to("POST /foo/@bar", [bar: %{id: "foo"}], %{baz: %{"id" => "thing"}})
        }
      end
    end
  end

  defmodule Resource.Foo.Bar_.POST do
    use Mazurka.Resource
    use Mazurka.Plug

    param bar

    mediatype Hyper do
      action do
        %{
          "Hello" => bar,
          "root" => link_to("/")
        }
      end
    end
  end

  @opts Router.init([])

  test "GET /" do
    conn(:get, "/")
    |> Router.call(@opts)
  end

  test "POST /foo/@bar" do
    conn(:post, "/foo/baz")
    |> Router.call(@opts)
  end

  test "GET /aint-exist" do
    assert_raise Plug.Conn.WrapperError, fn ->
      conn(:get, "/aint-exist")
      |> Router.call(@opts)
    end
  end

  test "resolve no exist" do
    %Mazurka.Affordance.Undefined{} =
      Router.resolve(%Mazurka.Affordance{}, nil, nil)
  end
end
