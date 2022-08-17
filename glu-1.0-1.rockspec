rockspec_format = "3.0"

package = "glu"
version = "1.0-1"

source = {
  url = "git+https://github.com/raygerlabs/glu.git",
  branch = "main"
}

description = {
  summary = "An extension plugin for Lustache in order to enable filters in mustache expressions",
  homepage = "https://github.com/raygerlabs/glu.git",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lustache"
}

test_dependencies = {
  "busted",
}

test = {
  type = "busted",
}

build = {
  type = "builtin",
  modules = {
    glu = "src/glu.lua"
  },
  copy_directories = {"", ""}
}
