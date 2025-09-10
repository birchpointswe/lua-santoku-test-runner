# santoku.test.runner

Test runner for executing Lua test files and directories.

## Module Reference

| Function | Arguments | Returns | Description |
|----------|-----------|---------|-------------|
| `runner` | `fps, [opts]` | `nil` | Executes test files and directories |

### Parameters

**`fps`** `table`  
Array of file paths to test. Each path can be:
- Individual test file
- Directory (runs all files recursively)
- Non-existent path (silently skipped)

**`opts`** `table` (optional)  
Configuration options:

| Field | Type | Description |
|-------|------|-------------|
| `interp` | `table` | Interpreter command array (e.g., `{"lua", "-l", "module"}`) |
| `match` | `string` | Pattern to filter files (uses Lua pattern matching) |
| `stop` | `boolean` | Stop on first test failure (default: continue) |

### Behavior

- Processes file paths sequentially
- Directories are traversed recursively for all files
- Non-existent paths are skipped without error
- Lua files (`.lua`) are executed in a sandboxed environment
- Other files are executed as system commands
- Test output is printed with "Test: filepath" prefix
- Errors are printed to stdout
- When `stop` is true, exits with code 1 on first failure