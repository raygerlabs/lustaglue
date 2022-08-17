require "busted.runner"()

describe("Mustache extension plugin", function()
  local l
  before_each(function()
    l = require("lustache")
  end)
  
  describe("when called without filters", function()
    local fmt, gl
    
    before_each(function()
      fmt = {}
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall keep backward compatibility", function()
      local template = "{{ name }}"
      local view = { name = "John Doe" }
      local result = l:render(template, view)
      local expected = view.name
      assert.same(result, expected)
    end)
  end)
  
  describe("when called with simple filter and no additional parameters", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        date = function(dt)
          return os.date("%Y-%m-%d", dt)
        end,
        upper = function(s)
          return s:upper()
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall execute the filter on the resolved string", function()
      local template = "{{ name | upper }}"
      local view = { name = "John Doe" }
      local result = l:render(template, view)
      local expected = "JOHN DOE"
      assert.same(result, expected)
    end)

    it("shall execute the filter on the resolved custom field", function()
      local template = "{{ registration_date | date }}"
      local view = { registration_date = os.time{year=2017, month=10, day=11} }
      local result = l:render(template, view)
      local expected = "2017-10-11"
      assert.same(result, expected)
    end)
  end)
  
  describe("when called with parametric filter and single parameter", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        add = function(x1, x2)
          return x1 + x2
        end,
        concat = function(s1, s2)
          return s1 .. s2
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall execute the filter with a single numeric parameter", function()
      local template = "{{ age | add: 10 }}"
      local view = { age = 10 }
      local result = l:render(template, view)
      local expected = "20"
      assert.same(result, expected)
    end)

    it("shall execute the filter with a single decimal parameter", function()
      local template = "{{ age | add: 0.1 }}"
      local view = { age = 10 }
      local result = l:render(template, view)
      local expected = "10.1"
      assert.same(result, expected)
    end)

    it("shall execute the filter with a single string parameter", function()
      local template = "{{ name | concat: ' Doe' }}"
      local view = { name = "John" }
      local result = l:render(template, view)
      local expected = "John Doe"
      assert.same(result, expected)
    end)
  end)

  describe("when called with parametric filters and multiple parameters", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        sum = function(x, ...)
          return x and x + fmt.sum(...) or 0
        end,
        wrap = function(str, _beg, _end)
          return _beg .. str .. _end
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall execute the filter with multiple numeric parameters", function()
      local template = "{{ weight | sum: 1: 2: 3: 4: 5: 6: 7: 8: 9 }}"
      local view = { weight = 10 }
      local result = l:render(template, view)
      local expected = "55"
      assert.same(result, expected)
    end)

    it("shall execute the filter with multiple decimal parameters", function()
      local template = "{{ weight | sum: 0.1: 0.2: 0.3: 0.4: 0.5: 0.6: 0.7: 0.8: 0.9 }}"
      local view = { weight = 10 }
      local result = l:render(template, view)
      local expected = "14.5"
      assert.same(result, expected)
    end)

    it("shall execute the filter with multiple string parameters", function()
      local template = "{{ name | wrap: '$(': ')' }}"
      local view = { name = "John Doe" }
      local result = l:render(template, view)
      local expected = "$(John Doe)"
      assert.same(result, expected)
    end)
  end)

  describe("when called with filter chaining", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        add = function(x1, x2)
          return x1 + x2
        end,
        concat = function(s1, s2)
          return s1 .. s2
        end,
        lower = function(s)
          return s:lower()
        end,
        lpad = function(str, len, delim)
          delim = delim or ' '
          return string.rep(delim, len - #str) .. str
        end,
        rpad = function(str, len, delim)
          delim = delim or ' '
          return str .. string.rep(delim, len - #str)
        end,
        sum = function(x, ...)
          return x and x + fmt.sum(...) or 0
        end,
        upper = function(s)
          return s:upper()
        end,
        wrap = function(str, _beg, _end)
          return _beg .. str .. _end
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall execute the filters in order", function()
      local template = "{{ name | upper | lower }}"
      local view = { name = "John Doe" }
      local result = l:render(template, view)
      local expected = "john doe"
      assert.same(result, expected)
    end)
    
    it("shall support parametric filters", function()
      local template = "{{ name | lpad: 10: '*' | rpad: 20: '#' }}"
      local view = { name = "John Doe" }
      local result = l:render(template, view)
      local expected = "**John Doe##########"
      assert.same(result, expected)
    end)
    
    it("shall support multiple parametric filters", function()
      local template = "{{ weight | add: 1 | add: 2 | add: 3 | add: 4 | add: 5 | add: 6 | add: 7 | add: 8 | add: 9 }}"
      local view = { weight = 10 }
      local result = l:render(template, view)
      local expected = "55"
      assert.same(result, expected)
    end)
  end)

  describe("when called with such parametric filters that has signed/unsigned parameters", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        add = function(x1, x2)
          return x1 + x2
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall evaluate numerical expressions", function()
      assert.same("11", l:render("{{ x | add: 1 }}", { x = 10 }))
      assert.same("11", l:render("{{ x | add: +1 }}", { x = 10 }))
      assert.same("9", l:render("{{ x | add: -1 }}", { x = 10 }))
    end)

    it("shall evaluate decimal expressions", function()
      assert.same("10.1", l:render("{{ x | add: 0.1 }}", { x = 10 }))
      assert.same("10.1", l:render("{{ x | add: +0.1 }}", { x = 10 }))
      assert.same("9.9", l:render("{{ x | add: -0.1 }}", { x = 10 }))
    end)
  end)

  describe("when called with such parametric filters that has nested expressions", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        add = function(x1, x2)
          return x1 + x2
        end,
        concat = function(s1, s2)
          return s1 .. s2
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall evaluate numerical expression", function()
      local template = "{{ zero | add: one }}"
      local view = { zero = 0, one = 1 }
      local result = l:render(template, view)
      local expected = "1"
      assert.same(result, expected)
    end)

    it("shall evaluate strings", function()
      local template = "{{ firstname | concat: lastname }}"
      local view = { firstname = "John", lastname = "Doe" }
      local result = l:render(template, view)
      local expected = "JohnDoe"
      assert.same(result, expected)
    end)

    it("shall evaluate complex numerical expressions", function()
      local template = "{{ weight | add: -10 | add: pi | add: -3 }}"
      local view = { weight = 10, pi = 3.14 }
      local result = l:render(template, view)
      local expected = "0.14"
      assert.same(result, expected)
    end)
  end)

  describe("when called with such parametric filters that contains quoted string parameters", function()
    local fmt, gl
    
    before_each(function()
      fmt = {
        concat = function(s1, s2)
          return s1 .. s2
        end,
      }
      gl = require("lustaglue"):new(fmt)
    end)
    
    it("shall allow single quotes", function()
      local template = "{{ name | concat: 'ny' }}"
      local view = { name = "John" }
      local result = l:render(template, view)
      local expected = "Johnny"
      assert.same(result, expected)
    end)

    it("shall allow double quotes", function()
      local template = "{{ name | concat: \"ny\" }}"
      local view = { name = "John" }
      local result = l:render(template, view)
      local expected = "Johnny"
      assert.same(result, expected)
    end)

    it("shall internal single quotes are converted into html escaped tags", function()
      local template = "{{ firstname | concat: ' \"Junior\" ' | concat: lastname }}"
      local view = { firstname = "John", lastname = "Doe" }
      local result = l:render(template, view)
      local expected = "John &quot;Junior&quot; Doe"
      assert.same(result, expected)
    end)

    it("shall internal double quotes are converted into html escaped tags", function()
      local template = "{{ firstname | concat: \" 'Junior\' \" | concat: lastname }}"
      local view = { firstname = "John", lastname = "Doe" }
      local result = l:render(template, view)
      local expected = "John &#39;Junior&#39; Doe"
      assert.same(result, expected)
    end)
  end)

end)