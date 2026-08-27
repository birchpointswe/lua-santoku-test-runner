local err = require("santoku.error")
local assert = err.assert
local pcall = err.pcall

local validate = require("santoku.validate")
local hasindex = validate.hasindex

local sys = require("santoku.system")
local execute = sys.execute

local fs = require("santoku.fs")
local exists = fs.exists
local runfile = fs.runfile
local files = fs.files
local isdir = fs.isdir

local arr = require("santoku.array")
local push = arr.push
local copy = arr.copy
local ieach = arr.ieach

local str = require("santoku.string")
local endswith = str.endswith
local smatch = string.match

local run_env = setmetatable({}, { __index = _G })

local function process_fp (fp, interp, match, stop)
  if fp and ((not match) or smatch(fp, match)) then
    print("Test:", fp)
    return (function (ok, ...)
      if stop and not ok then
        print(...)
        os.exit(1)
      elseif not ok then
        print(...)
      end
    end)(pcall(function ()
      if interp then
        execute(push(copy({}, interp), fp))
      elseif endswith(fp, ".lua") then
        runfile(fp, run_env)
      else
        execute({ fp })
      end
    end))
  end
end

return function (fps, opts)

  assert(hasindex(fps))
  opts = opts or {}
  assert(hasindex(opts))

  local interp = opts.interp
  local match = opts.match
  local stop = opts.stop

  for i = 1, #fps do
    local fp = fps[i]
    if exists(fp) then
      if isdir(fp) then
        ieach(function (f)
          process_fp(f, interp, match, stop)
        end, files(fp, true))
      else
        process_fp(fp, interp, match, stop)
      end
    end
  end

end
