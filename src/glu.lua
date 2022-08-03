-- file: glu.lua
--
-- Remove the trailing spaces from the specified string
--
string.trim = function(s)
  return s:match('^%s*(.*%S)') or ''
end
--
local glu = {filters={}}
--
-- Process the parameters in the filter expression:
-- {{ value | filter : param1 : param2 : param3 }}
--
function glu:parse_param(param, context)
  local stringExp = "^[\'\"](.*)[\'\"]$"
  local numericExp = "^[+-]?%d+$"
  local decimalExp = "^[+-]?%d%.%d+$"
  if param:match(stringExp)
  then
    return param:gsub(stringExp, "%1")
  end
  if param:match(decimalExp)
  then
    return tonumber(param)
  end
  if param:match(numericExp)
  then
    return tonumber(param)
  end
  return context:lookup(param)
end
--
-- Resolve filter# in a mustache expression:
-- {{ value | filter1 | filter2 | .. | filterN }}
--
function glu:exec_filter(expression, filter, context)
  local params = {expression}
  local tokens = string.split(filter, ":")
  local filter_name = string.trim(table.remove(tokens, 1)) -- The first element is always the filter!
  for _, token in ipairs(tokens) do -- Assemble the parameter list
    token = string.trim(token)
    token = self:parse_param(token, context)
    table.insert(params, token)
  end
  if self.filters[filter_name] ~= nil -- Check whether the specified filter exists or not
  then
    filter = self.filters[filter_name]
    expression = filter(table.unpack(params)) -- Call the filter
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
  local expression = table.remove(tokens, 1)  -- The first element is always the mustache expression!
  expression = string.trim(expression)
  expression = _lookup(self, expression) -- Search the cache in the context
  for _, token in ipairs(tokens) do -- Apply filters
    expression = glu:exec_filter(expression, token, self)
  end
  return expression
end
--
-- Construct the extension plugin
--
function glu:new(filters)
  local instance = {}
  setmetatable(instance, {__index=self})
  self.filters = filters
  return instance
end
--
return glu