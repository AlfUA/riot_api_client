# RiotApiClient
To start my app:

* Run `cd riot_api_client` to enter app directory
* Set the environment variable `RG_API` with your access token
* Run `mix compile` to compile
* Run `iex -S mix` to start shell
* Run from your shell `RiotApiClient.recent_summoners/2`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `riot_api_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:riot_api_client, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/riot_api_client>.

