require "busted.runner"()
--
local lustache = require "lustache"
local glue = require "glue"
--
describe("glue extension plugin", function()
  local lustache, glue, template, formatters, view, partials, expected
  setup(function()
    formatters = {
      lower = (function(s) return string.lower(s) end),
      upper = (function(s) return string.upper(s) end),
      wrap = (function(s, fst, lst) return fst..s..lst end),
    }
    lustache = require("lustache")
    glue = require("glue"):new(formatters)
  end)
  before_each(function()
    template = ""
    view = {}
    partials = {}
    expected = ""
  end)
  it("shall leave the original behaviour of mustache intact", function()
    --
    template = "{{ user }}"
    view = { user = "john" }
    expected = view.user
    --
    assert.same(expected, lustache:render(template, view, partials))
  end)
  it("shall execute a simple formatter expression", function()
    --
    template = "{{ user | upper }}"
    view = { user = "john" }
    expected = formatters["upper"](view.user)
    --
    assert.same(expected, lustache:render(template, view, partials))
  end)
  it("shall execute a chain of formatter expressions", function()
    --
    --
    template = "{{ user | upper | lower}}"
    view = { user = "john" }
    expected = formatters["upper"](view.user)
    expected = formatters["lower"](expected)
    --
    assert.same(expected, lustache:render(template, view, partials))
  end)
  it("shall execute a formatter string with parameters", function()
    --
    --
    template = "{{ user | wrap : 'hello, ' : ', how are you?' }}"
    view = { user = "john" }
    expected = formatters["wrap"](view.user, "hello, ", ", how are you?")
    --
    assert.same(expected, lustache:render(template, view, partials))
  end)
end)