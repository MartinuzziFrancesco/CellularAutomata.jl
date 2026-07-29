# Migration guide (to 0.1)

Version 0.1 reshapes the internals for automatic differentiation and future
neural-CA support. This page lists what changed and how to update calling code.

## Field access replaced with accessor functions

Struct fields are no longer public API; use the accessor functions instead.

| Before                | Now                                  |
|:---------------------- |:------------------------------------- |
| `automaton.evolution`  | `evolution_history(automaton)`       |
| `automaton.rule`       | `cellular_automaton_rule(automaton)` |
| `automaton.generations`| `generation_count(automaton)`        |
| `dca.ruleset`          | `rule_lookup_table(dca)`             |
| `dca.radius`           | `neighborhood_radius(dca)`           |
| `dca.states`           | `cell_state_count(dca)`              |

## Discrete rule states must have an `Integer` eltype

`DCA`/`TCA` now validate the state array and reject non-integer eltypes, even
when the values are integer-valued.

| Before          | Now                 |
|:---------------- |:-------------------- |
| `zeros(ncells)` | `zeros(Int, ncells)` |

## Abstract type hierarchy renamed

Only relevant if you dispatched on these types directly.

| Before                | Now                                            |
|:---------------------- |:------------------------------------------------ |
| `AbstractCA`          | `AbstractCellularAutomaton`                    |
| `AbstractRule`        | `AbstractCellularAutomatonRule`                |
| `AbstractODRule`      | dimension/kind-specific subtype (see below)    |
| `AbstractTDRule`      | dimension/kind-specific subtype (see below)    |
| `AbstractDCARule`     | `AbstractDiscreteCellularAutomatonRule`        |
| `AbstractCCARule`     | `AbstractContinuousCellularAutomatonRule`      |
| `AbstractTCARule`     | `AbstractTotalisticCellularAutomatonRule`      |
| `AbstractLifeRule`    | `AbstractLifeLikeCellularAutomatonRule`        |

## New functional core: `next_state`/`rollout`

The callable interface (`dca(state)`, `life(state)`, ...) still works, but now
delegates to `next_state`/`rollout`, which are the recommended entry points
going forward and required for AD use.

| Before                                | Now                                                  |
|:--------------------------------------- |:------------------------------------------------------ |
| `dca(state)`                          | `next_state(dca, state)` (or keep calling `dca(state)`)|
| `CellularAutomaton(rule, ic, n)` loop | `rollout(rule, ic, n; save=true)` for a bare trajectory|

## Boundary conditions are now explicit

Previously periodic wraparound was hardcoded. It is now the `Periodic()`
default of a new `AbstractBoundaryCondition` family, passed via the `boundary`
keyword. Default behavior is unchanged unless you relied on internal helpers.

| Before               | Now                                             |
|:---------------------- |:-------------------------------------------------- |
| (hardcoded periodic) | `next_state(rule, state; boundary=Periodic())`  |
|                      | `Reflecting()` and `ConstantBoundary(value)` also available |
