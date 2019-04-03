defmodule TaskManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_manager,
      version: "0.0.1",
      elixir: "~> 1.8.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      elixirc_paths: ["lib"],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      name: "task_manager",
      source_url: "https://github.com/qworks-io/task-manager.git",
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache 2.0"],
      maintainers: ["Slavo Vojacek", "Zoltan Arvai"],
      links: %{"GitHub" => "https://github.com/qworks-io/task-manager.git"}
    ]
  end

  defp description do
    "Provides Elixir.Task utilities"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19.3", only: :dev},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
