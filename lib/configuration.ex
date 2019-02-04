defmodule Spacebrew.Params do
  defstruct SPACEBREW_HOME: "~/.config/spacebrew"
end

defmodule Spacebrew.Configuration do
  @moduledoc """
  Configuration parser for the CLI tool.
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
    |> case do
         {:ok, config} -> config
         {:error, _}
       end
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
             {:ok, struct!(acc, parse_data(content))}
           {:error, error} ->
             Logger.info "\"#{x}\" file reading error: #{error}"
             {:error, acc}
         end
    end)
  end

  def get_config_from_env({_, params}) do
    {:ok, params}
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
