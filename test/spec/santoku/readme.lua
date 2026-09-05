local test = require("santoku.test")
local readme = require("santoku.test.readme")

test("README reproduces the anchor spec verbatim", function ()
  readme("test/spec/santoku/readme_anchor.lua")
end)
