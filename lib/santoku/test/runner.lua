local tup = require("santoku.tuple")
local err = require("santoku.err")
local gen = require("santoku.gen")
local fs = require("santoku.fs")
local sys = require("santoku.system")
local str = require("santoku.string")

local M = {}

M.MT_TEST = {
  __index = _G
}

M.run = function (files, interp, match, stop)
  local sent = tup()
  return err.pwrap(function (check)
    print()
    gen.ivals(files)
      :map(function (fp)
        if check(fs.isdir(fp)) then
          return fs.files(fp, { recurse = true }):map(check)
        else
          return gen.pack(fp)
        end
      end)
      :flatten()
      :each(function (fp)
        if not fp or match and not fp:match(match) then
          return
        end
        print("Test: " .. fp)
        if interp then
          local ok, e, cd = sys.execute(str.split(interp):append(fp):unpack())
          check.err(sent).ok(ok, e, cd)
        elseif str.endswith(fp, ".lua") then
          check.err(sent).ok(fs.loadfile(fp, setmetatable({}, M.MT_TEST)))()
        else
          local ok, e, cd = sys.execute(fp)
          check.err(sent).ok(ok, e, cd)
        end
      end)
  end, function (a, ...)
    if a == sent and stop then
      return false, ...
    elseif a == sent then
      print(...)
      return true
    else
      return a, ...
    end
  end)
end

return M
