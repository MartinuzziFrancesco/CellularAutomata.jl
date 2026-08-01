# Testing Cellular Automata as Random Number Generators

Wolfram proposed using the center column of a Rule 30 cellular automaton as a
pseudorandom-number generator. [`CellularAutomatonRNG`](@ref) implements that general
idea: any binary one-dimensional discrete rule can drive an `AbstractRNG` by reading
selected cells from successive generations.

This is an experimental generator, not a source of cryptographically secure randomness.
A cellular automaton that looks chaotic can still have biased or strongly correlated
output, so every rule and extraction configuration must be tested.

## Constructing a reproducible stream

An integer seed is mixed across the complete initial tape. The automaton then discards
`warmup * size` generations before returning output:

```@example rngtest
using CellularAutomata
using Random

rng = CellularAutomatonRNG(DCA(30); size = 127, seed = 1)
rand(rng, UInt8, 8)
```

Equal configurations and seeds reproduce the same stream. Integer draws consume one
contiguous sequence of CA bits: `UInt8`, `UInt16`, and `UInt64` consume 8, 16, and 64
bits respectively. Consequently, dumping `UInt8` values tests the advertised bitstream
without silently discarding intervening bits.

`CellularAutomatonRNG` rejects rules with more than two cell states. There is no generic
way to convert an arbitrarily correlated multi-state CA stream into provably unbiased
bits. In particular, a Von Neumann pair extractor requires independent, identically
distributed—or at least exchangeable—samples, which successive CA states do not
guarantee. Custom discrete rules must implement `cell_state_count(rule)` and report
exactly two states.

## A cheap initial screen

Bit balance and the longest constant run can reject obviously degenerate output. They
cannot establish that a generator is statistically sound.

```@example rngtest
function output_bits(rule, bit_count; size = 127, seed = 1)
    rng = CellularAutomatonRNG(rule; size = size, seed = seed)
    bytes = rand(rng, UInt8, cld(bit_count, 8))
    bits = [Int((byte >> shift) & 1) for byte in bytes for shift in 7:-1:0]
    return bits[1:bit_count]
end

function longest_run(bits)
    isempty(bits) && return 0
    longest = current = 1
    for index in 2:length(bits)
        current = bits[index] == bits[index - 1] ? current + 1 : 1
        longest = max(longest, current)
    end
    return longest
end

bits = output_bits(DCA(30), 5_000)
(balance = sum(bits) / length(bits), longest_run = longest_run(bits))
```

Repeat screens across several independently chosen seeds. Selecting a rule on one
stream and reporting that same stream as validation would overstate the evidence.

## Sampling more cells per generation

Reading only one cell requires a complete CA generation for every output bit. The
`skip` keyword instead reads every `skip`-th cell beginning at `start`:

```@example rngtest
center_rng = CellularAutomatonRNG(DCA(30); size = 127, seed = 1)
wide_rng = CellularAutomatonRNG(DCA(30); size = 127, seed = 1, start = 1, skip = 4)

rand(center_rng, UInt8, 4), rand(wide_rng, UInt8, 4)
```

This improves throughput, but the extracted stream is a different generator and needs
separate validation. For a radius-`r` rule, positions separated by at most `2r` have
overlapping input neighborhoods in the same generation. Choosing `skip > 2r` removes
that direct overlap; it does not prove independence.

Benchmark on the target machine rather than embedding timing output in doctests:

```julia
center_rng = CellularAutomatonRNG(DCA(30); size = 127, seed = 1)
wide_rng = CellularAutomatonRNG(DCA(30); size = 127, seed = 1, skip = 4)

rand(center_rng, UInt8, 1_000)
rand(wide_rng, UInt8, 1_000)

@time rand(center_rng, UInt8, 200_000)
@time rand(wide_rng, UInt8, 200_000)
```

## External statistical testing

Write a fresh, non-repeating byte stream for an external battery:

```julia
using CellularAutomata

function dump_random_stream(path, rule;
        byte_count = 2_000_000, size = 127, seed = 1, rng_kwargs...)
    rng = CellularAutomatonRNG(rule; size = size, seed = seed, rng_kwargs...)
    open(path, "w") do io
        write(io, rand(rng, UInt8, byte_count))
    end
    return path
end

dump_random_stream("rule30.bin", DCA(30))
dump_random_stream("rule30_skip4.bin", DCA(30); start = 1, skip = 4)
```

For example, Dieharder can consume the file through its raw-file generator:

```bash
dieharder -g 201 -f rule30.bin -d 100 -t 10000 -p 10
```

Ensure the command does not report that the input file was rewound. Reusing the same
finite block violates the test's fresh-sample assumption. Select `-t` and `-p` so the
requested data fit within the file, and record at least:

  - package version or commit;
  - rule, radius, tape size, seed, warmup, start, and skip;
  - byte count and checksum;
  - tool version and exact command;
  - complete output, including rewind diagnostics.

The implementation previously discarded 56 of every 64 generated bits when producing
each `UInt8`. Historical statistical tables obtained from that behavior do not test the
current contiguous stream and are intentionally not reproduced here. New statistical
claims require regenerating the data with the current implementation and retaining the
provenance listed above.

### Example results (illustrative only, not a validated claim)

The table below is a single run of the exact workflow described above. It exists to show
what the *procedure* produces, not to assert anything about any specific rule's quality —
one seed, `-p 10` psamples, and no repetition across independent seeds is precisely the
kind of screen this page cautions against treating as sufficient evidence elsewhere on
this page. Read it as a worked example of running the tests, not as a result to cite.

**Provenance**: CellularAutomata.jl `v0.1.3`; Dieharder `v3.31.1`; `size=127`, `seed=1`,
`skip=4`, `byte_count=20_000_000` per file; commands as above with `-t`/`-p` chosen so no
file rewind occurred (checked for every cell below).

| Test               | `DCA(30)`     | `DCA(1388968789; radius=2)` | `DCA(2427280835; radius=2)` | `TCA(3)` | `TCA(5)` |
|:------------------- |:-------------:|:----------------------------:|:----------------------------:|:--------:|:--------:|
| STS Monobit         | 0.648 PASSED  | FAILED                        | FAILED                        | 0.050 PASSED | 0.193 PASSED |
| STS Runs            | 0.433 PASSED  | FAILED                        | FAILED                        | FAILED       | FAILED       |
| Diehard Runs        | WEAK / PASSED | FAILED / FAILED               | FAILED / WEAK                  | FAILED / FAILED | FAILED / FAILED |
| Diehard Birthdays   | 0.099 PASSED  | FAILED                        | 0.409 PASSED                  | FAILED       | FAILED       |
| Diehard 32x32 Rank  | 0.989 PASSED  | FAILED                        | 0.904 PASSED                  | FAILED       | FAILED       |

What this single run happens to show, again as anecdote rather than proof:

  - `DCA(1388968789; radius=2)` — picked originally for a nice-looking heatmap, not for
    randomness — fails every test here, consistent with it collapsing toward a
    near-constant tape regardless of the initial condition.
  - `TCA(5)` was the best-scoring candidate out of an exhaustive screen of all 16
    possible `radius=1, states=2` totalistic rules (bit balance, longest run, and
    Lempel-Ziv complexity), yet it still fails 4 of 5 tests here — the cheap screen
    didn't just fail to *guarantee* quality, it failed to distinguish "best of a small
    pool" from an openly degenerate rule like `TCA(3)`.
None of this should be read as "Rule 30 is validated" or "TCA rules are bad" as general
claims — it's one seed, one run, a handful of reduced-sample tests. Run it yourself,
across multiple seeds, before drawing any conclusion you intend to rely on.

## Interpreting results

Passing a small battery is not evidence of cryptographic security, and a few convenient
tests are not a substitute for a preregistered validation protocol. Treat screening,
parameter selection, and final evaluation as separate stages, using different seeds or
held-out configurations. Report failures and weak results alongside passes.

[`lempel_ziv`](@ref) can provide an additional compressibility diagnostic, but it is
also only a screen. The generator should remain an educational and experimental tool
unless substantially stronger analysis supports a narrower claim.
