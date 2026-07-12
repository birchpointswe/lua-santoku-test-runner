local test = require("santoku.test")

local validate = require("santoku.validate")
local isfunction = validate.isfunction

local runner = require("santoku.test.runner")

test("runner is the callable entrypoint", function ()
  assert(isfunction(runner))
end)

test("non-existent paths are skipped without spawning", function ()
  runner({ "/no/such/spec/file.lua" })
  runner({ "/no/such/spec/file.lua" }, { match = "nomatch" })
end)
