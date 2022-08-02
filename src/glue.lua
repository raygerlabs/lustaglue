-- file: glue.lua
--

--
-- Remove spaces from string
--
function string.trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

local glue = {formatters={}}

--
-- Processes the formatter param to compatible format
--
local function process_param(param)
  if type(param) == "string" then
    -- Remove quotes from before and after
    param = param:gsub("^[\'\"](.*)[\'\"]$", "%1")
  end
  return param
end
--
-- Resolves a single filter# in a mustache expression:
-- {{ value | filter1 | filter2 | .. | filterN }}
--
function glue:apply_filter(expression, filter, lookup)
  -- Push the first element (the filter expression) in the list
  local params = {expression}
  
  -- Split the expression to parameters
  local elems = string.split(filter, ":")
  
  -- Get the filter name (it is always the first one in the expression)
  local filter_name = string.trim(table.remove(elems, 1))
  
  -- Process the parameter list of the formatter function:
  for _, elem in ipairs(elems) do
    elem = string.trim(elem)
    elem = process_param(elem)
    table.insert(params, elem)
  end
  
  -- Call the formatter function if present in the table
  if glue.formatters ~= nil and glue.formatters[filter_name] ~= nil then
    filter = glue.formatters[filter_name]
    expression = filter(table.unpack(params))
  end
  
  return expression
end

--
-- Constructs the new glue plugin.
--
function glue:new(formatters)
  local instance = {}
  setmetatable(instance, {__index=self})
  self.formatters = formatters
  return instance
end

--
-- Overrides the default context lookup function.
--
local context = require("lustache.context")
local _lookup = context.lookup
context.lookup = function(self, name)
  -- split formatters
  local formatters = string.split(name, "|")
  -- get the value
  local expression = table.remove(formatters, 1)
  expression = string.trim(expression)
  -- execute the original lookup function
  expression = _lookup(self, expression)
  -- resolving formatters...
  for _, formatter in ipairs(formatters) do
    expression = glue:apply_filter(expression, formatter, context.lookup)
  end
  return expression
end
--
return glue