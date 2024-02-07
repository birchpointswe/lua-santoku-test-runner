local err = require("santoku.error")
local assert = err.assert
local error = err.error
local pcall = err.pcall

local validate = require("santoku.validate")
local hasindex = validate.hasindex

local iter = require("santoku.iter")
local flatten = iter.flatten
local map = iter.map
local singleton = iter.singleton
local ivals = iter.ivals

local sys = require("santoku.system")
local execute = sys.execute

local fs = require("santoku.fs")
local runfile = fs.runfile
local isdir = fs.isdir

local varg = require("santoku.varg")
local tup = varg.tup

local arr = require("santoku.array")
local push = arr.push
local extend = arr.extend

local str = require("santoku.string")
local endswith = str.endswith
local smatch = string.match

local run_env = setmetatable({}, { __index = _G })

return function (fps, opts)

  assert(hasindex(fps))
  opts = opts or {}
  assert(hasindex(opts))

  local interp = opts.interp
  local match = opts.match
  local stop = opts.stop

  for fp in flatten(map(function (fp)
    if isdir(fp) then
      return files(fp, true)
    else
      return singleton(fp)
    end
  end, ivals(fps))) do
    if fp and not (match and smatch(fp, match)) then
      print("Test:", fp)
      return tup(function (ok, ...)
        if stop and not ok then
          error(...)
        elseif not ok then
          print(...)
        end
      end, pcall(function ()
        if interp then
          execute(push(extend({}, interp), fp))
        elseif endswith(fp, ".lua") then
          runfile(fp, run_env)
        else
          execute(fp)
        end
      end))
    end
  end

end
