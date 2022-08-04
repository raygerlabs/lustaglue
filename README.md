[![build](https://github.com/raygerlabs/glu/actions/workflows/build.yaml/badge.svg)](https://github.com/raygerlabs/glu/actions/workflows/build.yaml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![coverage](https://coveralls.io/repos/github/raygerlabs/glu/badge.svg)](https://coveralls.io/github/raygerlabs/glu)

# glu

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
local filter_functions = { ... }
local glu = require("glu"):new(filter_functions)
lustache:render(...)
```

### Examples

First, define some filter functions:

```
local filter_functions = {

  date=(function(dt)
    return os.date("%Y-%m-%d", dt.year, dt.month, dt.day)
  end),

  lower = (function(s)
    return string.lower(s)
  end),

  lpad=(function(str, len, delim)
    if delim == nil then delim = ' ' end
    return str .. string.rep(delim, len - #str)
  end),

  upper = (function(s)
    return string.upper(s)
  end),

  wrap = (function(s, fst, lst)
    return fst..s..lst
  end),
}
local glu = require("glu"):new(filter_functions)
```

Then create a template and a view:
```
local template = [[
  {{ name | upper }}
  {{ birth_date | date }}
  {{ id | lpad : 10 : '0' }}
]]

local view = {
  name = "John Doe",
  birth_date = { year = 1970, month = 10, day = 11 },
  id = 1234
}
```
Now, just call the renderer as usual:
```
lustache:render(template, view, {})
```

The result:
```
JOHN DOE
1970-10-11
0000001234
```
#### Filter chaining

We have the following filters and a view:
```
local filter_functions = {
  add=(function(a, b)
    return a + b
  end) 
}

local view = {
  zero = 0,
  one = 1
}
```
We can define the following template:
```
{{ zero | add: -10 }}
{{ zero | add: one }}
{{ zero | add: 1 | add: one | add: 3.14 }}
```

And the result will be:
```
-10
1
4.14
```

#### Text formatting filters

We have the following view:
```
local view = {
  first_name = "John",
  last_name = "Doe"
}
```

and filters:
```
local filter_functions = {
  concat=(function(a, b)
    return a..b
  end)
}
```

If we provide the following template:
```
{{ first_name | concat: 'ny' }}
{{ first_name | concat: \"ny\" }}
{{ first_name | concat: ' \"Junior\" ' | concat: last_name }}
{{ first_name | concat: \" 'Junior\' \" | concat: last_name }}
```

The result will be:
```
Johnny
Johnny
John &quot;Junior&quot; Doe
John &#39;Junior&#39; Doe
```
