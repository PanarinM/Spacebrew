# Spacebrew

**TODO: Add description**

## Configuration

This tool uses either configuration file or environmental variable.
Environmental variable takes precedence over the configuration file.

Configuration file should be named `.spacebrew` and can be placed in `~/` or
`~/.config/spacebrew`, with `~/` taking precedence.

All of the options from the config can be set and overridden with environmental
variables

### Options

Options for configuring is the home folder for the spacebrew files:
`SPACEBREW_HOME` with default value of `~/.config/spacebrew`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `spacebrew` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spacebrew, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/spacebrew](https://hexdocs.pm/spacebrew).
