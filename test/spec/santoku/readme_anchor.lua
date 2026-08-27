local test = require("santoku.test")

local err = require("santoku.error")
local assert = err.assert

local validate = require("santoku.validate")
local eq = validate.isequal

local fs = require("santoku.fs")
local runner = require("santoku.test.runner")

local function spec (name, body)
  fs.mkdirp("test/res")
  local fp = "test/res/" .. name
  fs.writefile(fp, body)
  return fp
end

local function ran (fps, opts)
  local seen = {}
  local print0 = print
  _G.print = function (_, fp) seen[#seen + 1] = fp end
  runner(fps, opts)
  _G.print = print0
  return seen
end

test("run every spec file given to it", function ()
  local a = spec("anchor_a.lua", "return true\n")
  local b = spec("anchor_b.lua", "return true\n")
  assert(eq(2, #ran({ a, b })))
  fs.rm(a, true)
  fs.rm(b, true)
end)

test("match filters files by lua pattern", function ()
  local a = spec("anchor_keep.lua", "return true\n")
  local b = spec("anchor_skip.lua", "return true\n")
  local seen = ran({ a, b }, { match = "keep" })
  assert(eq(1, #seen))
  assert(eq(a, seen[1]))
  fs.rm(a, true)
  fs.rm(b, true)
end)

test("paths that do not exist are skipped, not errors", function ()
  assert(eq(0, #ran({ "test/res/anchor_missing.lua" })))
end)
