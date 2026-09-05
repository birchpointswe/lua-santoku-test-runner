local err = require("santoku.error")
local assert = err.assert

local fs = require("santoku.fs")
local exists = fs.exists
local readfile = fs.readfile

local str = require("santoku.string")
local sfind = str.find

return function (anchor_fp, readme_fp)
  anchor_fp = anchor_fp or "test/spec/santoku/readme_anchor.lua"
  readme_fp = readme_fp or "README.md"
  assert(exists(readme_fp),
    readme_fp .. " not found beside the test tree: " ..
    "santoku-make copies it in from 3.7.0 onward, check the installed version")
  assert(exists(anchor_fp), "anchor spec not found: " .. anchor_fp)
  local readme = readfile(readme_fp)
  local spec = readfile(anchor_fp)
  assert(sfind(readme, "```lua\n" .. spec .. "```", 1, true) ~= nil,
    readme_fp .. " drifted from " .. anchor_fp ..
    ": the README must contain the anchor spec verbatim inside a ```lua fence, " ..
    "update one or the other so they match, then rerun toku test")
end
