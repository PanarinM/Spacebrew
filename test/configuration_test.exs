defmodule Spacebrew.Config.Test do
  use ExUnit.Case, async: true
  doctest Spacebrew.Config
  import Mox

  setup :verify_on_exit!

  test "config from file" do
    Spacebrew.ConfigMock
    |> expect(:paths, fn ->
      ["./examples/dot_spacebrew2",
       "./examples/dot_spacebrew",]
    end)

    assert Spacebrew.ConfigMock.get_config_from_file(
      %Spacebrew.Params{}) == %Spacebrew.Params{SPACEBREW_HOME: "mocked_data"}
  end
end
