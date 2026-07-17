# Differentiable cellular automata design

The rule objects are the user-facing abstraction, but simulation and history
allocation are separated from the local transition. This makes the transition usable
by automatic differentiation (AD), GPU arrays, and neural cellular automata (NCA)
without changing the existing discrete-rule API.

## Functional core API

```julia
next_state(rule, state; boundary=Periodic()) -> state
rollout(rule, state, steps; boundary=Periodic(), save=false) -> result
```

`next_state` is a pure function: it does not mutate `state` or captured parameter
arrays. `rollout` is the orchestration layer. It returns the final state by default,
which is the preferred path inside a loss function. With `save=true`, it returns the
initial state and all subsequent states with time on the last axis.
`CellularAutomaton` remains a compatibility wrapper and preserves its original
history layout.

Boundary behavior is represented by small types — `Periodic`, `Reflecting`, and
`ConstantBoundary` — rather than being embedded in every rule implementation.
Neighborhood extraction is likewise shared across rules.

## State and rule representation

Discrete automata accept vectors and matrices. Differentiable rules need a documented
channel convention; `channels × spatial... × batch` maps naturally to Julia's
column-major arrays and common Julia ML tooling. Code dispatches on `AbstractArray`
and never forces `Array` or `Float64`, so dual numbers and GPU arrays flow through
unchanged.

An NCA rule can subtype `AbstractCellularAutomatonRule` and contain a perception
operator and update network. ConcreteStructs keeps its parameter fields concretely
typed without manual type parameters:

```julia
using ConcreteStructs: @concrete

@concrete struct NeuralRule <: AbstractCellularAutomatonRule
    perceive
    update
end

spatial_dimensions(::NeuralRule) = 2

function CellularAutomata.next_state(rule::NeuralRule, x; boundary=Periodic())
    features = rule.perceive(x, boundary)
    return x + rule.update(features)
end
```

Trainable parameter discovery should be provided through the interface of the chosen
ML ecosystem (for example Functors.jl), while the core simulator does not depend on a
specific AD backend. Avoid custom derivative rules until profiling identifies an
operation for which generic AD is inadequate; then define a ChainRulesCore rule at
that narrow boundary.

## Migration sequence

 1. **Implemented:** pure `next_state`, functional `rollout`, explicit boundary types,
    shared neighborhood access, compatibility through `CellularAutomaton`, and
    multi-step ForwardDiff coverage. Lookup-based DCA/TCA and thresholded Life rules
    remain intentionally nondifferentiable.
 2. Test reverse-mode AD and GPU arrays after selecting the package's supported ML
    stack.
 3. Add a generic continuous multidimensional local rule with a documented
    `channels × spatial... × batch` layout.
 4. Add an optional package extension for the selected neural-network stack with
    `NeuralRule`, trainable-parameter integration, batched states, and GPU tests.
 5. Add checkpointed rollout or a custom reverse rule only when long unrolls show
    unacceptable memory use.

The important architectural boundary is that the simulator owns time and boundary
handling, while a rule owns only a single local state transition. That keeps
classical automata simple and gives learned rules a small, composable,
differentiable surface.
