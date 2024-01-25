local check = require("santoku.check")
local gen = require("santoku.gen")
local fs = require("santoku.fs")
local fun = require("santoku.fun")
local op = require("santoku.op")
local sys = require("santoku.system")
local str = require("santoku.string")

local M = {}

local MT = { __index = _G }

M.run = function (files, opts)
  opts = opts or {}
  return check:wrap(function (check)

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

        test_check = check:sub(function (...)
          if opts.stop then
            return false, ...
          else
            print(...)
            return true
          end
        end)

        if opts.interp then
          test_check(sys.execute(opts.interp_opts or {}, str.split(opts.interp)
            :filter(fun.compose(op["not"], str.isempty))
            :append(fp)
            :unpack()))
        elseif str.endswith(fp, ".lua") then
          test_check(fs.loadfile(fp, setmetatable({}, MT)))()
        else
          test_check(sys.execute(fp))
        end

      end)

  end)
end

return M
