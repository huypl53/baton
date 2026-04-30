---
name: daily:debug
description: Debug logic bugs and unexpected behavior by instrumenting code with logs and running it, instead of reading code and guessing. Use this skill whenever a test is failing, output is wrong, behavior is unexpected, a function "isn't working," or you're tempted to reason about what the code *should* do — reach for logs + a real run to get evidence before proposing a fix. Especially important in Python where types, shapes, None-ness, and off-by-one issues hide in plain sight.
---

# Debug with logging

## The core mistake to avoid

When a logic bug appears, the tempting flow is: read the code → form a hypothesis → propose a fix → maybe apply it → user reports it still doesn't work → new hypothesis → repeat.

This is slow and often wrong. The code you're reading is the code that produced the bug — re-reading it rarely reveals what your first reading missed. What you lack is **evidence about runtime values**, and the fastest way to get that evidence is to instrument the code and run it.

**Rule of thumb:** If you've read the code once and don't immediately see the bug, stop reading and start logging. One well-placed log + one run usually beats three rounds of speculation.

## When to apply this

Trigger this approach for:
- A test fails and the error message doesn't make the cause obvious.
- Output is wrong but the code "looks right."
- Something works for one input and not another.
- You're about to write a sentence like "I think the issue might be..." — that's the cue to stop thinking and start measuring.
- Debugging anything involving types, None/null, empty collections, off-by-one, or data that came from outside (files, APIs, user input).

Skip it (read the code instead) for:
- Pure syntax errors — the traceback already tells you.
- Errors with a crystal-clear traceback pointing at one line.
- Code you haven't read at all yet — do one pass first, *then* log if the bug isn't obvious.

## Where to place logs

Don't sprinkle logs everywhere. Think about **information flow** and log at boundaries:

1. **Function entry and exit of the suspected function** — what came in, what went out.
2. **Immediately before and after any transformation** — parsing, type conversion, filtering, aggregation, API calls, DB queries. Bugs cluster at transformations.
3. **Branch points** — which branch of an `if`/`match` was actually taken.
4. **Loop iterations** — especially the first, last, and any iteration where state changes unexpectedly.
5. **Just before the failing assertion or the line that raises** — capture the state that produced the failure.

If the code is large and you don't know where the bug is, **binary search**: log at the midpoint, run, see whether the value is already wrong there, then narrow to the half that contains the bug.

## What to log

Logging "reached here" is almost useless. Log **values with context**. For each logged value include:

- A **label** identifying where the log came from (function name, or a short tag).
- The **value itself** — use `repr()` in Python, not `str()`. `repr()` shows quotes, reveals `'5'` vs `5`, shows `None` vs `'None'`, and survives weird whitespace.
- **Type and size** for anything non-scalar: `type(x).__name__`, `len(x)`, and for numpy/pandas also `.shape` and `.dtype`.
- **Identifying context** if inside a loop or a multi-request flow: the id, index, or key of the item being processed.

### Python example

```python
# Bad:
print("got data")
print(data)

# Good:
print(f"[load_users] data type={type(data).__name__} len={len(data)} first={data[0] if data else None!r}")
```

For dicts, log keys first (`list(d.keys())`) — the values might be huge, but a missing or misspelled key is the single most common Python bug and is visible from just the keys.

For pandas DataFrames: `df.shape`, `df.columns.tolist()`, `df.dtypes`, and `df.head(2)` — not the whole frame.

For numpy arrays: `arr.shape`, `arr.dtype`, and a small slice.

## How to run

1. **Use the smallest input that reproduces the bug.** If a test case fails, run just that one test. If a function misbehaves on one record, feed it that record directly in a tiny script. Large inputs hide the signal in noise.
2. **Run once, read the output, then decide the next move.** Don't add more logs speculatively — let what you saw guide the next log placement.
3. **Iterate by narrowing.** Each run should either confirm the bug's location is in region A or region B, and the next round of logs goes into the confirmed region.

Expect 2–4 iterations. If you're past 4 and still lost, the logging strategy is wrong — zoom out and log at a higher level (the caller, the data source) rather than deeper.

## Make logs distinctive and removable

- **Prefix debug logs** with something greppable like `DBG:` or `[debug]`. This makes them easy to find and strip later, and easy to filter in output.
- In production code or a codebase with existing logging infrastructure, use `logger.debug(...)` rather than `print`, so the logs can be toggled with log levels instead of deleted.
- **Clean up before finishing.** Once the bug is fixed, remove the `DBG:` prints (or leave well-formed `logger.debug` calls that will stay silent by default). Don't leave scattered `print` statements in the final diff — it's noisy and signals half-finished work.

## Python tooling notes

- `print(f"{x=}")` prints `x=<value>` — the `=` specifier is the fastest way to log a variable with its name. Use it.
- `pprint.pp(obj)` for nested dicts/lists that are hard to read on one line.
- For async or multi-threaded code, include a timestamp or task id in the log prefix, because ordering is not guaranteed.
- If the codebase already uses `logging`, match it. Create a logger at module top: `logger = logging.getLogger(__name__)` and use `logger.debug(...)`. Make sure the root logger is configured to show DEBUG (`logging.basicConfig(level=logging.DEBUG)`) when running the repro — otherwise your logs won't appear and you'll think the code isn't reaching them.
- `breakpoint()` is an alternative when you need to poke around interactively, but for agent work, logs + a re-run are usually faster and more reproducible than an interactive session.

## A worked example

Bug report: "`calculate_discount(order)` returns 0 for this order but should return 15."

**Tempting approach:** read `calculate_discount`, notice it checks `order.customer.tier`, hypothesize the tier is wrong, propose a fix.

**Better approach:**

```python
def calculate_discount(order):
    print(f"DBG [calc_discount] order.id={order.id!r} customer={order.customer!r}")
    tier = order.customer.tier
    print(f"DBG [calc_discount] tier={tier!r} type={type(tier).__name__}")
    if tier == "gold":
        print("DBG [calc_discount] -> gold branch")
        return 15
    print("DBG [calc_discount] -> default branch, returning 0")
    return 0
```

Run once. Output:

```
DBG [calc_discount] order.id='A-123' customer=<Customer id=42>
DBG [calc_discount] tier='Gold' type=str
DBG [calc_discount] -> default branch, returning 0
```

Now the bug is obvious and visible: tier is `'Gold'` (capitalized) but the comparison is against `'gold'`. Zero reading of docs, zero guessing. Fix is `tier.lower() == "gold"` or normalize upstream. This took one run and ~5 lines of logging to find what might have taken several rounds of hypothesizing.

## Summary

Evidence beats speculation. When a logic bug resists a first reading, your next move is **log → run → read output → narrow**, not read → guess → propose.
