[![build](https://github.com/raygerlabs/lustaglue/actions/workflows/build.yaml/badge.svg)](https://github.com/raygerlabs/lustaglue/actions/workflows/build.yaml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![coverage](https://coveralls.io/repos/github/raygerlabs/lustaglue/badge.svg)](https://coveralls.io/github/raygerlabs/lustaglue)

# lustaglue

An extension plugin for Lustache in order to enable custom formatters in expressions such as
```
{{ variable | filter1 | filter2 | ... | filterN }} 
```

## Installation

Using luarocks:

```
 luarocks install lustaglue
```

Or from source:
```
git clone https://github.com/raygerlabs/lustaglue
cd lustaglue
luarocks make
```

See the luarock here:
https://luarocks.org/modules/raygerlabs/lustaglue

## Usage

### Definitions

A filter is such an expression that alters the output of the rendering function. A filter can defined using the following syntax:
```
{{ variable | filter }}
```

A filter can be applied on the result of another filter such as:
```
{{ variable | filter1 | filter2 | ... | filterN }}
```

A filter that has parameters called parametric filter. The syntax is the following:
```
{{ variable | filter : param1 : param2 : ... : paramN }}
```

### Workflow

```
local lustache = require "lustache"

local filters = {...}
local lustaglue = require("lustaglue"):new(filters)

local template = {...}
local view = {...}

lustache:render(template, view)
```

## Examples

### Simple filters

Given the following filter and view:
```
local filters = {
  upper = (function(s)
    return string.upper(s)
  end),
}
local view = { name = "John Doe" }
```

The template
```
{{ name | upper }}
```

shall produce:
```
JOHN DOE
```

### Parametric filters

Given the following filter and view:
```
local filters = {
  add=(function(a, b)
    return a + b
  end) 
}
local view = {
  ten = 10
}
```
The template
```
{{ ten | add: 10 }}
```
shall produce
```
20
```

### Expression as parameters

Given the following filter and view:
```
local filters = {
  add=(function(a, b)
    return a + b
  end) 
}
local view = {
  ten = 10,
  twenty = 20
}
```
The template
```
{{ ten | add: twenty }}
```
shall produce
```
30
```

### Filter chaining

The filter functions are chainable. Given the following filter and view:
```
local filters = {
  add=(function(a, b)
    return a + b
  end),
  sum=(function(x, ...)
    return x and x + filters.sum(...) or 0
  end)
}
local view = {
  ten = 10,
  twenty = 20
}
```

With the following template:
```
{{ ten | add: -10 }}
{{ ten | add: twenty }}
{{ ten | add: ten | add: twenty | add: 30 | add: 40 | add: 50 }}
{{ ten | sum: 10: 20: 30: 40: 50 }}
```

And the result will be:

```
0
30
80
160
160
```

### Quotes

Given the following filter and view:
```
local filter_functions = {
  concat=(function(a, b)
    return a..b
  end)
}
local view = {
  first_name = "John",
  last_name = "Doe"
}
```

The template:
```
{{ first_name | concat: 'ny' }}
{{ first_name | concat: \"ny\" }}
{{ first_name | concat: ' \"Junior\" ' | concat: last_name }}
{{ first_name | concat: \" 'Junior\' \" | concat: last_name }}
```

shall produce:
```
Johnny
Johnny
John &quot;Junior&quot; Doe
John &#39;Junior&#39; Doe
```
