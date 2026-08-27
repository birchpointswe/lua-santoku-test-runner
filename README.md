# santoku-test-runner

Test harness that runs spec files. The module returns a single function,
`runner(fps, opts)`, that walks a list of paths and executes each spec file,
optionally filtering by pattern and stopping on the first failure. The `toku`
build framework uses it to run a project's `test/spec` suite. Built on base
`santoku`, `santoku-system` (to spawn an interpreter), and `santoku-fs` (to
discover and run files). See [../lua-santoku/README.md](../lua-santoku/README.md),
[../lua-santoku-system/README.md](../lua-santoku-system/README.md), and
[../lua-santoku-fs/README.md](../lua-santoku-fs/README.md) for those surfaces.

Documentation and runnable examples: [santoku.dev](https://santoku.dev), under the
`santoku-test-runner` tab.

This README is a usage guide, not an API reference. The tests are the spec:
`test/spec/santoku/test/runner.lua` exercises the entrypoint's shape, its
path-skipping behavior, and each of the three dispatch branches (interpreter
subprocess, in-process `.lua`, and direct command), including the error raised
when a spawned file exits non-zero.

## Usage

```lua
local runner = require("santoku.test.runner")

runner({ "test/spec" }, {
  interp = { "lua", "-l", "santoku.profile" },
  match = "%.lua$",
  stop = true,
})
```

`fps` is an array of paths. Each entry is run in order:

- A directory is traversed recursively (via `santoku.fs.files`); every file
  found is processed.
- A file is processed directly.
- A path that does not exist is skipped without error.

`opts` is optional and honors three fields:

- `interp`: an array forming an interpreter command. When set, each file is run
  as a subprocess by appending the file path to a copy of this array and calling
  `santoku.system.execute`. When unset, a `.lua` file is loaded in-process with
  `santoku.fs.runfile` under an environment whose `__index` is `_G`; any other
  file is executed directly as a command.
- `match`: a Lua pattern. A file is processed only when its path matches.
- `stop`: when true, the first failing file prints its error and exits the
  process with status 1. When false (the default), failures are printed and the
  run continues.

Each processed file prints `Test:` followed by its path before running. Failures
are caught with `santoku.error.pcall` and printed to stdout.

covers: `test/spec/santoku/test/runner.lua`.

## License

MIT License

Copyright 2025 Birch Point SWE

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
