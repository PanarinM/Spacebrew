defmodule Spacebrew.Params do
  defstruct SPACEBREW_HOME: "~/.config/spacebrew"
end

defmodule Spacebrew.ConfigReader do
  @callback get_config_values(%Spacebrew.Params{}, [String.t()]) :: %Spacebrew.Params{}
end

defmodule Spacebrew.ConfigReader.Env do
  @moduledoc """
  Config parser for the CLI tool.
  """
  require Logger

  @behaviour Spacebrew.ConfigReader

  @doc """
  Reads the data from Environmental variables defined in the Spacebrew.Params struct
  """
  @impl Spacebrew.ConfigReader
  def get_config_values(params, vars) do
    vars
    |> Enum.reduce(params, fn x, acc ->
      env_value = x
      |> System.get_env
      if env_value != nil do
        Logger.info "Env variable value #{x} found, using it"
        struct!(acc, [{String.to_atom(x), env_value}])
      else
        Logger.info "Env variable value #{x} not found, pass"
        acc
      end
    end)
  end
end

defmodule Spacebrew.ConfigReader.File do
  @moduledoc """
  Config parser for the CLI tool.
  """
  require Logger

  @behaviour Spacebrew.ConfigReader


  @doc """
  Reads the data from configuration files cascading through them in order of
  paths
  """
  @impl Spacebrew.ConfigReader
  def get_config_values(params, paths) do
    Enum.reduce(paths, params, fn x, acc ->
      read_file(x)
      |> case do
           {:ok, content} ->
             Logger.info "\"#{x}\" file found, parsing"
             struct!(acc, parse_data(content))
           {:error, error} ->
             Logger.info "\"#{x}\" file reading error: #{error}"
             acc
         end
    end)
  end


  defp read_file(path) do
    Path.expand(path)
    |> File.read
    |> case do
      {:ok, content} -> {:ok, String.split(content, "\n", trim: true)}
      {:error, error} -> {:error, error}
    end
  end

  defp parse_data(data) do
    Enum.map(data, fn x ->
      String.split(x, "=", parts: 2, trim: true)
    end)
    |> Map.new(fn [x, y] -> {String.to_atom(x), y} end)
  end
end

defmodule Spacebrew.Config.API do

  @doc """
  Returns the configuration tuple.
  """
  def get_config do
    %Spacebrew.Params{}
    |> Spacebrew.ConfigReader.File.get_config_values(paths())
    |> Spacebrew.ConfigReader.Env.get_config_values(vars())
  end

  @doc """
  Paths to check for config files
  """
  def paths do
    [
      # The order is important here
      "~/.config/spacebrew/.spacebrew",
      "~/.spacebrew",
    ]
  end

  @doc """
  Returns env variables to read
  """
  def vars do
    %Spacebrew.Params{}
    |> Map.keys
    |> Enum.flat_map(fn x ->
      if x == :__struct__ do
        []
      else
        [to_string(x)]
      end
    end)
  end
end
