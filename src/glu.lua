--- file: glu.lua

--- Trim trailing whitespaces from a specific string.
--- @param s string
--- @return expression string
function string.trim(s)
  assert(type(s) == "string", "string type expected for argument 's'")
  return s:match("^%s*(.*%S)") or ''
end

--- @class glu
local glu = {
  _VERSION = "1.0",
  _NAME = "glu",
  filters={}
}

--- Filter separators
local sep = {
  filter = '|',
  param = ':'
}

--- Process parametric expression in a filter, such as:
--- {{ value | filter : param1 : param2 : param3 }}
--- @param param string
--- @param context table
--- @return expression string
function glu:parse_param(param, context)
  -- For determining the type of the expression within the string:
  local stringExp = "^[\'\"](.*)[\'\"]$"
  local numericExp = "^[+-]?%d+$"
  local decimalExp = "^[+-]?%d%.%d+$"

  -- Remove opening and closing quotes from the parameter expression when it's a string
  if param:match(stringExp) then
    return param:gsub(stringExp, "%1")
  end
  
  -- Convert to number when it's a number
  if param:match(decimalExp) or param:match(numericExp) then
    return tonumber(param)
  end
  
  -- None of the above
  -- Search in the context table...
  return context:lookup(param)
end

--- Resolve filter# in a mustache expression:
--- {{ value | filter1 | filter2 | .. | filterN }}
--- @param value the element from the context table
--- @param filter the expression string
--- @param context table
--- @return expression string
function glu:exec_filter(value, filter, context)
  -- Add data to the parameter table
  -- This is the data we want to transform by filters!
  local params = {value}
  -- Break up the expression for filter and parameters:
  local tokens = string.split(filter, sep.param)
  -- The first parameter should always be the filter itself.
  filter = string.trim(table.remove(tokens, 1))
  
  -- Resolve the filter
  local callback = self.filters[filter]
  if callback then
    -- OK - Let's generate the parameter list
    for _, token in ipairs(tokens) do
      token = self:parse_param(string.trim(token), context)
      table.insert(params, token)
    end
    -- Call the filter
    value = callback(table.unpack(params))
  end

  return value
end

--- Override lookup function in the context
local context = require "lustache.context"

--- Local copy of the lookup function in Lustache context
local _lookup = context.lookup

--- Search the cache for a specific entry.
--- @param self the reference of context
--- @param name the template name
--- @return expression string
function context.lookup(self, name)
  -- Break up the expression for any potential filters and mustache expression:
  local tokens = string.split(name, sep.filter)
  
  -- The first element should always be the original expression.
  -- Call the original lookup function (resolve the data from the context table):
  local expression = string.trim(table.remove(tokens, 1))
  local value = _lookup(self, expression)

  -- Transform the value by the given filter (if any)
  for _, token in ipairs(tokens) do
    value = glu:exec_filter(value, token, self)
  end

  return value
end

--- Construct the extension plugin.
--- @param filters table
--- @return glu extension table
function glu:new(filters)
  local instance = {}
  setmetatable(instance, {__index=self})
  self.filters = filters
  return instance
end

return glu
