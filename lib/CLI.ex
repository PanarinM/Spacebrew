defmodule Spacebrew.CLI do
  @moduledoc """
  CLI tool to manage Spacemacs config files for different pruposes.
  """

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
    parsed_args = Optimus.new!(
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

    configurations = get_config
  end

  def subcommand({[:new], %Optimus.ParseResult{args: args, options: options}}) do
  end
end
