# Benchmarks

The `benchmarks/` directory contains a set of benchmarks, mostly for primitive operations.

The entry point is the `benchmarks/benchmarks.shen` file.

Ports that use the `launcher` extension can launch it as a script. When launched as a script all the benchmark tests will be executed and each timing reported to the standard output as soon as it becomes available.

If this file is loaded instead, the benchmarks can be started by calling the `run-all-benchmarks` function. It takes as an argument a function that defines how reporting is handled.

The two predefined reporting functions are:

- `stoutput-report` -- prints the results to the standard output (used when running in script mode).
- `save-report` - stores the results in the `*benchmark-results*` variable as a list of results, each with the format `[Tag Description RunsPower StartTime EndTime]`. `Tag` is unused for now, `Description` is a string describing the test, `RunsPower` is the amount of times the test was repeated (10^RunsPower), and `StartTime` and `EndTime` are the times when the test started and ended. The total time is `(- EndTime StartTime)`.
