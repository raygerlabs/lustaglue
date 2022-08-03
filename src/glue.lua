-- file: glue.lua
--
--local context = require("lustache.context")
--
-- Remove the trailing spaces from the specified string
--
string.trim = function(s)
  return s:match('^%s*(.*%S)') or ''
end
--
-- Define glue module
--
local glue = {formatters={}}
--
-- Process the current parameter in the filter expression:
-- {{ value | filter : param1 : param2 : param3 }}
--
function glue:parse_param(param, context)
  local stringExp = "^[\'\"](.*)[\'\"]$"
  local numericExp = "^[+-]?%d+$"
  local decimalExp = "^[+-]?%d%.%d+$"
  if param:match(stringExp) then -- remove single and double quotes around the string
    return param:gsub(stringExp, "%1")
  end
  if param:match(numericExp) then -- Q: since lua 5.3
    return math.tointeger(param)
  end
  if param:match(decimalExp) then -- all numbers are decimals in Lua
    return tonumber(param)
  end
  return context:lookup(param) -- then it's an expression
end
--
-- Resolves a single filter# in a mustache expression:
-- {{ value | filter1 | filter2 | .. | filterN }}
--
function glue:exec_filter(expression, filter, context)
  local call_list = {expression}
  local param_list = string.split(filter, ":")
  local filter_name = string.trim(table.remove(param_list, 1)) -- The first element in the table is always the filter name itself
  for _, param in ipairs(param_list) do
    param = string.trim(param)
    param = self:parse_param(param, context)
    table.insert(call_list, param)
  end
  if self.formatters[filter_name] ~= nil then -- Call the formatter functions in the table
    filter = self.formatters[filter_name]
    expression = filter(table.unpack(call_list))
  end
  return expression
end
--
-- Override lookup function in the context
--
local context = require "lustache.context"
local _lookup = context.lookup
function context.lookup(self, name)
  local formatters = string.split(name, "|")
  local expression = table.remove(formatters, 1)  -- The first element in the table is always the mustache variable itself
  expression = string.trim(expression)
  expression = _lookup(self, expression) -- Calling lookup function from the context
  for _, formatter in ipairs(formatters) do
    expression = glue:exec_filter(expression, formatter, self)
  end
  return expression
end
--
-- Construct the glue plugin.
--
function glue:new(formatters)
  local instance = {}
  setmetatable(instance, {__index=self})
  self.formatters = formatters
  return instance
end
--
return glue