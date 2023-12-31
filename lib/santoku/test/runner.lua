local err = require("santoku.err")
local gen = require("santoku.gen")
local fs = require("santoku.fs")
local sys = require("santoku.system")
local str = require("santoku.string")

local M = {}

local MT = { __index = _G }

M.run = function (files, opts)
  opts = opts or {}
  return err.pwrap(function (check)

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

        if not fp or opts.match and not fp:match(opts.match) then
          return
        end

        print("Test: " .. fp)

        check = check:tag("test")

        if opts.interp then
          check(sys.execute(opts.interp_opts or {}, str.split(opts.interp):append(fp):unpack()))
        elseif str.endswith(fp, ".lua") then
          check(fs.loadfile(fp, setmetatable({}, MT)))()
        else
          check(sys.execute(fp))
        end

      end)

  end, function (tag, ...)

    if tag ~= "test" or opts.stop then
      return false, ...
    else
      print(...)
      return true
    end

  end)
end

return M
