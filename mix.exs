defmodule Multipipe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :multipipe,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
       licenses: ["Apache 2"],
       links: %{"GitHub" => "https://github.com/johnnyfeng/multipipe"},
       maintainers: ["Johnny Feng"]
    ]
  end
end
