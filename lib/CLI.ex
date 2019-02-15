defmodule Spacebrew.CLI do
  @moduledoc """
  CLI tool to manage Spacemacs config files for different purposes.
  """
  # import Spacebrew.Config

  @doc """
  Main function spawning Optimus and parsing arguments.
  """
  def main(arguments) do
    # TODO: Clean this example
    # {[:new],
    #  %Optimus.ParseResult{
    #    args: %{name: "test"},
    #    flags: %{},
    #    options: %{template: "/home/m-panarin/.spacemacs"},
    #    unknown: []
    #  }}
    Optimus.new!(
      name: "spacebrew",
      description: "Config brewer for Spacemacs.",
      about: """
      CLI tool to manage Spacemacs config files for different purposes.
      """,
      version: "0.0.1",
      author: "Panarin Mykhailo mykhailopanarin@gmail.com",
      subcommands: [
        new: [
          name: "new",
          about: "Creates a config using a template.",
          allow_unknown_args: true,
          parse_double_dash: true,
          args: [
            name: [
              value_name: "NAME",
              help: "Name for the config",
              required: true,
              parser: :string,
            ]
          ],
          options: [
            template: [
              value_name: "TEMPLATE",
              help: "Template for the config",
              parser: :string,
              default: Path.expand("~/.spacemacs"),
              short: "-t",
              long: "--template",
            ]
          ],
        ],
        # list: [],
        # FIXME: this should be changed to be a simple command and not a subcommad.
        # set: []
      ]
    )
    |> Optimus.parse!(arguments)
    |> get_config
    |> subcommand
  end

  def subcommand({[:new], %Optimus.ParseResult{args: args, options: options}, config}) do
    IO.puts "this was the 'new' command"
    IO.inspect args
    IO.inspect options
    IO.inspect config
  end
  def get_config(command) do
    command
    |> Tuple.append(Spacebrew.Config.API.get_config)
  end
end
