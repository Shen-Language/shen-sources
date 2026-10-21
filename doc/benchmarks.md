# Benchmarks

The `benchmarks/` directory contains a set of benchmarks, mostly for primitive operations.

The entry point is the `benchmarks/benchmarks.shen` file.

Ports that use the `launcher` extension can launch it as a script. When launched as a script all the benchmark tests will be executed and each timing reported to the standard output as soon as it becomes available.

If this file is loaded instead, the benchmarks can be started by calling the `run-all-benchmarks` function. It takes as an argument a function that defines how reporting is handled.

The two predefined reporting functions are:

- `stoutput-report` -- prints the results to the standard output (used when running in script mode).
- `save-report` - stores the results in the `*benchmark-results*` variable as a list of results, each with the format `[Tag Description RunsPower StartTime EndTime]`. `Tag` is unused for now, `Description` is a string describing the test, `RunsPower` is the amount of times the test was repeated (10^RunsPower), and `StartTime` and `EndTime` are the times when the test started and ended. The total time is `(- EndTime StartTime)`.


## Additional operation and composition coverage

The suite includes ordinary-sized workloads for costs that isolated reads,
writes and simple calls do not cover. They live alongside the related cases:

| Suite | Added coverage |
| --- | --- |
| `data.shen` | List traversal, length, recursive rebuilding, append, reverse, first/last/absent membership, and list/closure allocation with three retained generations. |
| `control-flow.shen` | Returning calls with zero/one/three managed survivors, an allocating recursive callee, and a captured caller. |
| `pattern-matching.shen` | Nested list matching, early failure and late failure, complementing the existing list/tuple/vector/string cases. |
| `equality-check.shen` | Distinct equal lists/trees/vectors, early/late mismatches and integer/fractional equality. |
| `arithmetic.shen` | Integer and integer/fractional addition and multiplication. |

These 29 cases use the normal registration/reporting API and category tags.
Existing cases and run powers are unchanged; additional cases follow the old
cases within each file. The arithmetic suite is loaded by the normal entry point.
Registration positions consequently change: a runner selecting only the first
48 rows must select cases by description/tag to retain its intended coverage.
Historical frozen inputs and results are separate and should remain unchanged.

Lists and vectors contain 32 items. Distinct input construction and initial
benchmark closures are prepared at registration, before timing. Rebuilding and
allocation cases intentionally allocate inside the measured loop. The three
leaf returning-call controls use the same identity callee, 32-item returned tail
and three-cell reconstruction, with a shared dynamic outer harness. Survivor
counts describe source-level managed values used after the inner call; they do
not promise physical registers, root counts or frame layouts.

The allocation windows stay bounded and create ordinary allocation pressure.
They do not force collection or guarantee nursery misses on every port; those
claims require a port's independent checks and accounting. No runtime hooks or
kernel implementation changes are involved.

Run the registration/result smoke check in a fresh process from the repository
root. It loads the normal entry point and checks all 29 additions at one and three
iterations, unique descriptions, tags and run powers, without timed execution:

```sh
./shen-scheme/bin/shen-scheme eval -l tests/benchmark-coverage.shen \
  -e '(benchmark-coverage.run)'
```

Use `eval`, not `script`, for that check. Script mode invokes the benchmark entry
point's full timing run. Keep preparation/execution, historical comparisons and
GC diagnostics explicit when publishing measurements; the smoke check supplies
no performance result.
