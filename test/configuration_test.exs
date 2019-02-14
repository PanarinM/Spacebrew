defmodule Spacebrew.Config.Test do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  # test "config from file" do
  #   Spacebrew.ConfigMock
  #   |> expect(:paths, fn ->
  #     ["./examples/dot_spacebrew2",
  #      "./examples/dot_spacebrew",]
  #   end)
  #   |> expect(:get_config_from_file, &Spacebrew.Config.get_config_from_file/1)

  #   assert Spacebrew.ConfigMock.get_config_from_file(
  #     %Spacebrew.Params{}) == %Spacebrew.Params{SPACEBREW_HOME: "mocked_data"}
  # end
  test "config from file" do
    paths = [
      "./test/examples/dot_spacebrew2",
    ]
    assert Spacebrew.ConfigReader.File.get_config_values(
      %Spacebrew.Params{}, paths) == %Spacebrew.Params{
      SPACEBREW_HOME: "lowest_importance"
    }
    # Previous value will get overwritten by next file
    paths = [
      "./test/examples/dot_spacebrew2",
      "./test/examples/dot_spacebrew",
    ]
    assert Spacebrew.ConfigReader.File.get_config_values(
      %Spacebrew.Params{}, paths) == %Spacebrew.Params{
      SPACEBREW_HOME: "mid_importance"
    }
  end

  test "config from env" do
    System.put_env("SPACEBREW_HOME", "test_value")

    assert Spacebrew.ConfigReader.Env.get_config_values(
      %Spacebrew.Params{}) == %Spacebrew.Params{
      SPACEBREW_HOME: "test_value"
    }
  end

  test "config priority" do
      Spacebrew.ConfigFromFileMock
      |> expect(:get_config_values, fn x, y ->
        %Spacebrew.Params{SPACEBREW_HOME: "from_file"}
      end)
      |> expect(:read_from, fn -> [] end)

      Spacebrew.ConfigFromEnvMock
      |> expect(:get_config_values, fn x, y ->
        %Spacebrew.Params{SPACEBREW_HOME: "from_env"}
      end)
      |> expect(:read_from, fn -> [] end)

      config = Spacebrew.Config.API.get_config(
        [Spacebrew.ConfigFromFileMock,
          Spacebrew.ConfigFromEnvMock]
      )
      assert config = %Spacebrew.Params{SPACEBREW_HOME: "from_env"}
  end
end
