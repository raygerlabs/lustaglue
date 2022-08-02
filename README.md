# glue

An extension plugin for Lustache in order to enable filters in mustache expressions.

### Filters

A filter is such an expression that alters the output of the rendering function. A filter can defined using the following syntax:
```
{{ variable | filter }}

```

A filter can be applied on the result of another filter such as:
```
{{ variable | filter1 | filter2 | ... | filterN }}
```

A filter may have parameters. The syntax:
```
{{ variable | filter : param1 : param2 : ... : paramN }}
```

### Usage

```
local lustache = require "lustache"
local glue = require "glue"
local formatters = { ... }
glue = glue:new(formatters)
lustache:render(...)
```

### Example

First, specify some filters:

```
local formatters = {
      lower = (function(s) return string.lower(s) end),
      upper = (function(s) return string.upper(s) end),
      wrap = (function(s, fst, lst) return fst..s..lst end),
}
```

Now, create a template and a view.

```
lustache:render("{{ name | upper }}", { name = "john doe"})
```

The result:
```
JOHN DOE
```
