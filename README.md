# concerto_plug

Plug integration for Concerto

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `concerto_plug` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:concerto_plug, "~> 0.1.0"}]
    end
    ```

## Usage

```elixir
defmodule MyRouter do
  use Concerto, [root: "#{System.cwd!}/fixtures",
                 ext: ".ex",
                 module_prefix: MyApp.Resource]

  use Concerto.Plug.Mazurka
end
```
