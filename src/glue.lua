-- file: glue.lua
--
function string.trim(s)
  return s:gsub("%s+", "") 
end
--
local glue = {formatters={}}
--
-- Resolve a single filter# in a mustache expression:
-- {{ value | filter1 | filter2 | .. | filterN }}
--
function glue:apply_filter(expr, fltr, lookup)
  local params = expr
  if glue.formatters ~= nil and glue.formatters[fltr] ~= nil then
    fltr = glue.formatters[fltr]
    return fltr(params)
  end
  return expr
end
--
function glue:new(formatters)
  local instance = {}
  setmetatable(instance, {__index=self})
  self.formatters = formatters
  return instance
end
--
local context = require("lustache.context")
local _lookup = context.lookup
context.lookup = function(self, name)
  name = string.trim(name)
  local formatters = string.split(name, "|")
  local expr = table.remove(formatters, 1)
  -- call the lookup function
  expr = _lookup(self, expr)
  -- apply formatters
  for _, fltr in ipairs(formatters) do
    expr = glue.apply_filter(self, expr, fltr, context.lookup)
  end
  return expr
end
--
return glue