--[[
    switch.lua
    @Whims-Dev on Github

    It's like switch case from C++

    Usage:
    local switch = require(path.to.switch).new
    switch(expression)
        .case(x, function)
        .case(y, function)
        .case(z, function)
        .run(reexpression?)

    switch(expression):
        This is like doing if (expression == x), but in a more compressed manner.
        Returns a dictionary with the following functions... ⬇️

    .case(x, function(x) -> ()):
        A case that gets stored in a "cases" table, doesn't do anything until .run() is used.
        "x" will also be resent to the function just in case you're using the same function for all cases.

    .run(reexpression?):
        Loop through "cases" to match "x" to "expression" before running the first matching case.
        "reexpression" is not required. It's recommended if you want to reuse the switch case but need to test different values.

    .clean(): Clears the cases table then clears the switch table
--]]

local module = {}

function module.new(expression)
    local self = {}
    local cases = {}
    self.case = function(case, func)
        table.insert(cases, {case, func})
        return self
    end
    self.run = function(reexpression)
        local expression = reexpression or expression
        for i, v in ipairs(cases) do
            if (v[1] == expression) then
                v[2](expression)
                break
            end
        end
    end
    self.clean = function()
        table.clear(cases)
        table.clear(self)
    end
    
    return self
end

return module
