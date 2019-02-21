defmodule Spacebrew.Params do
  defstruct SPACEBREW_HOME: "~/.config/spacebrew"
end

defmodule Spacebrew.ConfigReader do
  @callback get_config_values(%Spacebrew.Params{}, [String.t()]) :: %Spacebrew.Params{}
  @callback read_from() :: [String.t()]
end

defmodule Spacebrew.ConfigReader.Env do
  @moduledoc """
  Config parser for the CLI tool.
  """
  require Logger

  @behaviour Spacebrew.ConfigReader

  @doc """
  Returns env variables to read
  """
  @impl Spacebrew.ConfigReader
  def read_from do
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

  @doc """
  Reads the data from Environmental variables defined in the Spacebrew.Params struct
  """
  @impl Spacebrew.ConfigReader
  def get_config_values(params, vars_list \\ read_from()) do
    vars_list
    |> Enum.reduce(params, fn x, acc ->
      env_value = x
      |> System.get_env
      if env_value != nil do
        Logger.info "Env variable value #{x} found, using it"
        struct!(acc, [{String.to_atom(x), env_value}])
      else
        Logger.info "Env variable value #{x} not found, skip"
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
  Paths to check for config files
  """
  @impl Spacebrew.ConfigReader
  def read_from do
    [
      # The order is important here
      "~/.config/spacebrew/.spacebrew",
      "~/.spacebrew",
    ]
  end

  @doc """
  Reads the data from configuration files cascading through them in order of
  paths
  """
  @impl Spacebrew.ConfigReader
  def get_config_values(params, paths_list \\ read_from()) do
    Enum.reduce(paths_list, params, fn x, acc ->
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

  require Logger
  @doc """
  Returns the configuration tuple.
  """
  def get_config(readers \\ [Spacebrew.ConfigReader.File, Spacebrew.ConfigReader.Env]) do
    Enum.reduce(readers, %Spacebrew.Params{}, fn x, acc ->
      x.get_config_values(acc, x.read_from)
    end)
    |> check_config_values
  end

  def check_config_values(config) do
    config
    |> check_path_exists
  end

  defp check_path_exists(config) do
    path =
      Map.get(config, :SPACEBREW_HOME)
      |> Path.expand
    path
    |> File.dir?
    |> unless do
      Logger.info("\"#{path}\" doesn't exist. Creating...")
      File.mkdir_p!(path)
    end
    config
  end

end
