defmodule Pipelinex.Mixfile do
  use Mix.Project

  def project do
    [app: :pipelinex,
     version: "0.1.0",
     elixir: "~> 1.4",
     name: "Pipelinex",
     description: description(),
     package: package(),
     deps: deps(),
     source_url: "https://github.com/PhillippOhlandt/pipelinex"]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    []
  end

  defp description do
    """
    Pipelinex is a simple library to build data pipelines in a clean and structured way.

    It's mainly built for personal usage to help with structuring big data processing flows
    and automatically apply things like logging, which otherwise would make the code very unclean.
    """
  end

  defp package do
    [
      maintainers: ["Phillipp Ohlandt"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/PhillippOhlandt/pipelinex"}
    ]
  end
end
