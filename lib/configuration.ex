defmodule Spacebrew.Params do
  defstruct SPACEBREW_HOME: "~/.config/spacebrew"
end

defmodule Spacebrew.Config do
  @moduledoc """
  Config parser for the CLI tool.
  """
  require Logger

  @paths [
    # The order is important here
    "~/.config/spacebrew/.spacebrew",
    "~/.spacebrew",
  ]

  @doc """
  Returns the configuration tuple.
  """
  def get_config do
    %Spacebrew.Params{}
    |> get_config_from_file
    |> get_config_from_env
  end

  @doc """
  Reads the data from configuration files cascading through them in order of
  @paths
  """
  def get_config_from_file(params) do
    Enum.reduce(@paths, params, fn x, acc ->
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

  @doc """
  Reads the data from Environmental variables defined in the Spacebrew.Params struct
  """
  def get_config_from_env(params) do
    params
    |> Map.keys()
    |> Enum.filter(fn x -> x != :__struct__ end)
    |> Enum.reduce(params, fn x, acc ->
      env_value = x
      |> to_string
      |> System.get_env
      if env_value != nil do
        Logger.info "Env variable value #{x} found, using it"
        struct!(acc, [{x, env_value}])
      else
        Logger.info "Env variable value #{x} not found, pass"
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
      [key, value] = String.split(x, "=", parts: 2, trim: true)
    end)
    |> Map.new(fn [x, y] -> {String.to_atom(x), y} end)
  end
end
