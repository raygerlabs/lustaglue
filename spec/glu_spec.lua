require "busted.runner"()
--
string.lpad = function(str, len, char)
  if char == nil then char = ' ' end
  return str .. string.rep(char, len - #str)
end
--
describe("mustache extension plugin", function()
  local lustache, view, filter_functions, glu
  before_each(function()
    lustache = require("lustache")
    view = { name = "John Doe", age = 10, birth = { year = 1990, month = 9, day = 9 } }
    filter_functions = {
      add=(function(a, b)
        if type(a) == "string" then
          return a .. b
        else
          return a + b
        end
      end),
      date=(function(dt)
        return os.date("%Y-%m-%d", dt.year, dt.month, dt.day)
      end),
      lpad=(function(s, n, c)
        return string.lpad(s, n, c)
      end),
      lower=(function(s)
        return string.lower(s)
      end),
      sum=(function(a, ...)
        return a and a + filter_functions.sum(...) or 0
      end),
      upper=(function(s)
        return string.upper(s)
      end),
      wrap=(function(s, _beg, _end)
        return _beg..s.._end
      end),
    }
    glu = require("glu"):new(filter_functions)
  end)
  describe("expressions without formatters", function()
    it("shall keep backward compatibility", function()
      assert.same(lustache:render("{{ name }}", view, {}), view.name)
    end)
  end)

  describe("expressions with a single formatter", function()
    it("shall execute the formatter with expression value as parameter", function()
      assert.same(lustache:render("{{ name | upper }}", view, {}), string.upper(view.name))
      assert.same(lustache:render("{{ birth |date }}", view, {}), filter_functions["date"](view.birth))
    end)
  end)

  describe("expressions with parametric formatters", function()
    it("shall execute the formatter with an additional string parameter", function()
      assert.same(lustache:render("{{ name | add : ' welcomes thee!' }}", view, {}), view.name.." welcomes thee!")
    end)
    it("shall execute the formatter with an additional numeric parameter", function()
      assert.same(lustache:render("{{ name | lpad : 10 }}", view, {}), string.lpad(view.name, 10))
    end)
    it("shall execute the formatter with an additional decimal parameter", function()
      assert.same(lustache:render("{{ age | add: 0.5 }}", view, {}), "10.5")
    end)
    it("shall execute the formatter with multiple additional string parameter", function()
      assert.same(lustache:render("{{ name | wrap : '${' : '}' }}", view, {}), "${"..view.name.."}")
    end)
    it("shall execute the formatter with multiple additional numeric parameter", function()
      assert.same(lustache:render("{{ age | sum : 1 : 2: 3 : 4 : 5 : 6 : 7 : 8 : 9 }}", view, {}), "55")
    end)
    it("shall execute the formatter with multiple additional decimal parameter", function()
      assert.same(lustache:render("{{ age | sum : 0.1 : 0.2: 0.3 : 0.4 : 0.5 : 0.6 : 0.7 : 0.8 : 0.9 }}", view, {}), "14.5")
    end)
  end)

  describe("expressions with chained formatters", function()
    it("shall execute the formatters in order", function()
      assert.same(lustache:render("{{ name | lower | upper }}", view), string.upper(view.name))
    end)
    it("shall support parametric formatters", function()
      assert.same(lustache:render("{{ name | lpad:10:'*' | lpad:20:'#' }}", view), string.lpad(string.lpad(view.name, 10, '*'), 20, '#'))
    end)
    it("shall support many parametric formatters", function()
      assert.same(lustache:render("{{ age | add:1 | add:2 | add:3 | add:4 | add:5 | add:6 | add:7 | add:8 | add:9 }}", view), "55")
    end)
  end)

  describe("parametric formatter types", function()
    local view
    setup(function()
      view = { firstname="John", lastname="Doe", zero=0, pi=3.141593  }
    end)
    it("shall allow numeric parameter", function()
      assert.same(lustache:render("{{ zero | add: 1 }}", view), '1')
      assert.same(lustache:render("{{ zero | add: +1 }}", view), '1')
      assert.same(lustache:render("{{ zero | add: -1 }}", view), '-1')
    end)
    it("shall allow decimal parameter", function()
      assert.same(lustache:render("{{ zero | add: 0.1 }}", view), '0.1')
      assert.same(lustache:render("{{ zero | add: +0.1 }}", view), '0.1')
      assert.same(lustache:render("{{ zero | add: -0.1 }}", view), '-0.1')
    end)
    it("shall allow other expressions as parameters", function()
      assert.same(lustache:render("{{ zero | add: pi }}", view, {}), ""..view.pi)
      assert.same(lustache:render("{{ firstname | add: lastname }}", view), view.firstname..view.lastname)
    end)
    it("shall allow quoted string parameters", function()
      assert.same(lustache:render("{{ firstname | add: 'ny' }}", view), 'Johnny')
      assert.same(lustache:render("{{ firstname | add: \"ny\" }}", view), 'Johnny')
      -- Lustache renders text with HTML escape characters by default
      assert.same(lustache:render("{{ firstname | add: ' \"Junior\" ' | add: lastname }}", view), 'John &quot;Junior&quot; Doe')
      assert.same(lustache:render("{{ firstname | add: \" 'Junior\' \" | add: lastname }}", view), "John &#39;Junior&#39; Doe")
    end)
  end)

end)