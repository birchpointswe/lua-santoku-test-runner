<p align="center">
  <img src="https://santoku.dev/logo-santoku-test-runner.png" height="64" alt="santoku-test-runner">
</p>

# santoku-test-runner

The spec runner behind `toku test`. One function walks a list of paths, executes each
spec file it finds, and reports failures. Lua files run in-process, anything else runs as
a command, and `interp` runs each file through an interpreter of your choosing.

## Install

```sh
luarocks install santoku-test-runner
```

## Example

```lua
local runner = require("santoku.test.runner")

runner({ "test/spec" }, { match = "sqlite", stop = true })
```

Directories are walked recursively. `match` filters by Lua pattern, and `stop` halts at
the first failure instead of running the whole suite.

## Documentation

Runnable examples and the full API:
[santoku.dev](https://santoku.dev/#santoku-test-runner).

For agents and LLM tooling: [llms.txt](https://santoku.dev/llms.txt) for the index,
[llms-full.txt](https://santoku.dev/llms-full.txt) for every documented example.

## Tests

The tests are the spec. For the exhaustive surface, read them:
[`test/spec/santoku/test/runner.lua`](test/spec/santoku/test/runner.lua).

## License

MIT, see [LICENSE](LICENSE).

## More examples

```lua
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
```
