ExUnit.start()

Mox.defmock(Spacebrew.ConfigFromFileMock, for: Spacebrew.ConfigReader)
Mox.defmock(Spacebrew.ConfigFromEnvMock, for: Spacebrew.ConfigReader)
