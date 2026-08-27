local test = require("santoku.test")

local err = require("santoku.error")
local pcall = err.pcall

local validate = require("santoku.validate")
local isfunction = validate.isfunction
local isequal = validate.isequal

local arr = require("santoku.array")
local apush = arr.push
local amap = arr.map
local apack = arr.pack
local acat = arr.concat

local str = require("santoku.string")
local sfind = str.find

local fs = require("santoku.fs")
local mkdirp = fs.mkdirp
local writefile = fs.writefile
local readfile = fs.readfile
local rm = fs.rm

local sys = require("santoku.system")
local execute = sys.execute
local sh = sys.sh

local runner = require("santoku.test.runner")

local shell

local function shell_path ()
  if not shell then
    for line in sh({ "sh", "-c", "command -v sh" }) do
      shell = shell or line
    end
  end
  assert(shell)
  return shell
end

local function write_exe (fp, body)
  mkdirp("test/res")
  rm(fp, true)
  writefile(fp, "#!" .. shell_path() .. "\n" .. body)
  execute({ "chmod", "+x", fp })
  return fp
end

local function capture (fps, opts)
  local lines = {}
  local print0 = print
  _G.print = function (...)
    apush(lines, acat(amap(apack(...), tostring), " "))
  end
  local ok, e = pcall(runner, fps, opts)
  _G.print = print0
  assert(ok, tostring(e))
  return acat(lines, "\n")
end

test("runner is the callable entrypoint", function ()
  assert(isfunction(runner))
end)

test("non-existent paths are skipped without spawning", function ()
  runner({ "/no/such/spec/file.lua" })
  runner({ "/no/such/spec/file.lua" }, { match = "nomatch" })
end)

test("lua files without an interpreter run in-process", function ()
  mkdirp("test/res")
  local fp = "test/res/runner_inproc.lua"
  local out = "test/res/runner_inproc.out"
  rm(out, true)
  writefile(fp, "require('santoku.fs').writefile('" .. out .. "', 'inproc')\n")
  capture({ fp })
  assert(isequal("inproc", readfile(out)))
  rm(fp, true)
  rm(out, true)
end)

test("non-lua files without an interpreter run as commands", function ()
  local out = "test/res/runner_exec.out"
  local fp = write_exe("test/res/runner_exec.sh", "echo ran > " .. out .. "\n")
  rm(out, true)
  local printed = capture({ fp })
  assert(isequal("ran\n", readfile(out)))
  assert(sfind(printed, "Test: " .. fp, nil, true))
  rm(fp, true)
  rm(out, true)
end)

test("a non-zero exit from a command file is a structured error", function ()
  local fp = write_exe("test/res/runner_fail.sh", "exit 3\n")
  local printed = capture({ fp })
  assert(sfind(printed, "child process exited with unexpected status exited 3", nil, true))
  rm(fp, true)
end)

test("interp runs each file through the configured interpreter", function ()
  mkdirp("test/res")
  local fp = "test/res/runner_interp.in"
  local out = "test/res/runner_interp.out"
  rm(out, true)
  writefile(fp, "")
  capture({ fp }, { interp = { "sh", "-c", "echo \"$0\" > " .. out } })
  assert(isequal(fp .. "\n", readfile(out)))
  rm(fp, true)
  rm(out, true)
end)
