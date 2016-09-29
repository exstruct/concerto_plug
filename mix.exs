defmodule Concerto.Plug.Mixfile do
  use Mix.Project

  def project do
    [app: :concerto_plug,
     description: "Plug integration for Concerto",
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:concerto, ">= 0.0.0"},
     {:plug, ">= 0.0.0"},
     {:mazurka, ">= 1.0.0", only: [:dev, :test]},
     {:mazurka_plug, ">= 0.0.0", only: [:dev, :test]},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/exstruct/concerto_plug"}]
  end
end
