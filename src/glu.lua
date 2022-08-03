-- file: glu.lua
--
--local context = require("lustache.context")
--
-- Remove the trailing spaces from the specified string
--
string.trim = function(s)
  return s:match('^%s*(.*%S)') or ''
end
--
-- Define glu module
--
local glu = {filters={}}
--
-- Process the current parameter in the filter expression:
-- {{ value | filter : param1 : param2 : param3 }}
--
function glu:parse_param(param, context)
  local stringExp = "^[\'\"](.*)[\'\"]$"
  local numericExp = "^[+-]?%d+$"
  local decimalExp = "^[+-]?%d%.%d+$"
  if param:match(stringExp) then -- Remove single and double quotes around the string
    return param:gsub(stringExp, "%1")
  end
  if param:match(numericExp) then
    return math.tointeger(param) -- Available since Lua 5.3; we must preserve backward compatibility somehow...
  end
  if param:match(decimalExp) then -- All numbers are decimals in Lua
    return tonumber(param)
  end
  return context:lookup(param) -- If none of the above is fulfilled then search the cache
end
--
-- Resolves a single filter# in a mustache expression:
-- {{ value | filter1 | filter2 | .. | filterN }}
--
function glu:exec_filter(expression, filter, context)
  local params = {expression}
  local tokens = string.split(filter, ":")
  local filter_name = string.trim(table.remove(tokens, 1)) -- The first element in the table is always the filter!
  for _, token in ipairs(tokens) do -- Assemble the parameter list for the filter function
    token = string.trim(token)
    token = self:parse_param(token, context)
    table.insert(params, token)
  end
  if self.filters[filter_name] ~= nil then -- Call the filter function
    filter = self.filters[filter_name]
    expression = filter(table.unpack(params))
  end
  return expression
end
--
-- Override lookup function in the context
--
local context = require "lustache.context"
local _lookup = context.lookup
function context.lookup(self, name)
  local tokens = string.split(name, "|")
  local expression = table.remove(tokens, 1)  -- The first part of the expression is always the mustache expression
  expression = string.trim(expression)
  expression = _lookup(self, expression) -- Process the expression as usual
  for _, token in ipairs(tokens) do -- Apply the filters
    expression = glu:exec_filter(expression, token, self)
  end
  return expression
end
--
-- Construct the glue plugin.
--
function glu:new(filters)
  local instance = {}
  setmetatable(instance, {__index=self})
  self.filters = filters
  return instance
end
--
return glu