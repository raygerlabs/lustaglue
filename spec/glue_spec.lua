require "busted.runner"()
--
local lustache = require "lustache"
local glue = require "glue"
--
describe("glue", function()
  local template, formatters, view, partials, expected
  before_each(function()
    template = ""
    formatters = {}
    view = {}
    partials = {}
    expected = ""
  end)
  it("should a normal mustache expression evaluates", function()
    --
    formatters = {
      lower = (function(s) return string.lower(s) end),
      upper = (function(s) return string.upper(s) end),
      wrap = (function(s, b, e) return b..s..e end),
    }
    glue = glue:new(formatters)
    --
    template = "{{ user }}"
    view = { user = "john" }
    expected = view.user
    --
    assert.same(expected, lustache:render(template, view, partials))
  end)
  it("should an expression with a single formatter evaluates", function()
    --
    formatters = {
      lower = (function(s) return string.lower(s) end),
      upper = (function(s) return string.upper(s) end),
      wrap = (function(s, b, e) return b..s..e end),
    }
    glue = glue:new(formatters)
    --
    template = "{{ user | upper }}"
    view = { user = "john" }
    expected = string.upper(view.user)
    --
    assert.same(expected, lustache:render(template, view, partials))
  end)
end)