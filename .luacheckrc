unused_args     = false
redefined       = false
max_line_length = false
include_files = {
  "**/*.lua",
  ".busted",
  "*.rockspec",
  ".luacheckrc",
}
files["**/spec/**/*_spec.lua"].std = "+busted"
files["**/*.rockspec"].std = "+rockspec"
files["**/*.luacheckrc"].std = "+luacheckrc"
exclude_files = {
  -- GH Actions Lua Environment
  ".lua",
  ".luarocks",
}