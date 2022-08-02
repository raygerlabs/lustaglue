package = "glue"
version = "1.0-0"
source = {
  url = "https://github.com/raygerlabs/glue.git",
  dir = "glue-1.0-0"
}
description = {
  summary = "Extension library for lustache plugin in order to enable formatters in mustache expressions such as {{ variable | filter1 | filter2 | ... | filterN }}",
  homepage = "https://github.com/raygerlabs/glue.git",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
  "lustache",
  "busted"
}
build = {
  type = "builtin",
  modules = {
    ["glue"] = "src/glue.lua"
  }
}
