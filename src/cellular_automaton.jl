"""
    AbstractCellularAutomaton

Supertype for cellular automata that retain an evolution history.
"""
abstract type AbstractCellularAutomaton end

"""
    next_state(rule, state; boundary=Periodic(), scheme=Synchronous(), rng=nothing)

Apply one cellular-automaton transition without mutating `state`. Rule subtypes
define their transition by implementing
`CellularAutomata.__step(rule, state, boundary)`; this wrapper then applies the
selected update scheme.

# Arguments

  - `rule`: Cellular-automaton transition rule.
  - `state`: Current state array.

# Keyword arguments

  - `boundary`: Boundary condition used outside the state array.
    Defaults to `Periodic()`.
  - `scheme`: Update scheme controlling which cells apply the transition.
    Defaults to `Synchronous()`; use `Stochastic(rate)` for a per-cell random mask.
  - `rng`: Random number generator used by stochastic schemes. It must be supplied
    explicitly with `Stochastic` and its state advances when the mask is drawn.
    It is not consulted by `Synchronous`.

# Examples

```jldoctest
julia> using CellularAutomata

julia> next_state(DCA(30), [0, 0, 1, 0, 0])
5-element Vector{Int64}:
 0
 1
 1
 1
 0
```
"""
function next_state(
        rule::AbstractCellularAutomatonRule,
        state;
        boundary::AbstractBoundaryCondition = Periodic(),
        scheme::AbstractUpdateScheme = Synchronous(),
        rng::Union{Nothing, AbstractRNG} = nothing
    )
    __validate_state(rule, state)
    __validate_scheme_rng(scheme, rng)
    new_state = __step(rule, state, boundary)
    return __apply_scheme(scheme, rng, state, new_state)
end

@concrete struct __Transition
    rule
    boundary
    scheme
    rng
end

function (transition::__Transition)(state, _)
    return next_state(
        transition.rule, state;
        boundary = transition.boundary, scheme = transition.scheme, rng = transition.rng
    )
end

"""
    rollout(rule, initial_state, steps; boundary=Periodic(), scheme=Synchronous(),
        rng=nothing, save=false)

Apply `steps` transitions of `rule` to `initial_state`. By default only the final
state is returned, which is the preferred path inside a loss function. With
`save=true`, return the initial state and every subsequent state stacked with time
on the last axis.

# Arguments

  - `rule`: Cellular-automaton transition rule.
  - `initial_state`: State from which to begin the rollout.
  - `steps`: Number of transitions to apply.

# Keyword arguments

  - `boundary`: Boundary condition used by each transition. Defaults to `Periodic()`.
  - `scheme`: Update scheme applied at every step. Defaults to `Synchronous()`.
  - `rng`: Random number generator passed to every step. It must be supplied
    explicitly with `Stochastic`; the same object is reused and its state advances
    across steps. It is not consulted by `Synchronous`.
  - `save`: Retain the initial state and every subsequent state. Defaults to `false`.

# Examples

```jldoctest
julia> using CellularAutomata

julia> history = rollout(DCA(30), [0, 0, 1, 0, 0], 2; save=true);

julia> size(history)
(5, 3)

julia> history[:, end]
5-element Vector{Int64}:
 1
 1
 0
 0
 1
```
"""
function rollout(
        rule::AbstractCellularAutomatonRule,
        initial_state,
        steps::Integer;
        boundary::AbstractBoundaryCondition = Periodic(),
        scheme::AbstractUpdateScheme = Synchronous(),
        rng::Union{Nothing, AbstractRNG} = nothing,
        save::Bool = false
    )
    steps >= 0 || throw(ArgumentError("steps must be nonnegative"))
    isempty(initial_state) && throw(ArgumentError("initial_state cannot be empty"))
    __validate_scheme_rng(scheme, rng)
    transition = __Transition(rule, boundary, scheme, rng)
    if save
        states = accumulate(transition, 1:steps; init = initial_state)
        return stack(Iterators.flatten(((initial_state,), states)))
    end
    return foldl(transition, 1:steps; init = initial_state)
end

"""
    CellularAutomaton(rule, initial_conditions, generations)

Construct a cellular automaton and retain its complete evolution history. For vector
states, `evolution_history(automaton)` stores time on the first axis. For
higher-dimensional states, time is stored on the last axis.

# Arguments

  - `rule`: Cellular-automaton rule defining one transition.
  - `initial_conditions`: Initial state array.
  - `generations`: Number of retained generations, including the initial state.

# Examples

```jldoctest
julia> using CellularAutomata

julia> automaton = CellularAutomaton(DCA(30), [0, 1, 0], 3)
CellularAutomaton with 3 generations
  rule: DCA(30; states=2, radius=1)
  evolution: 3×3 Matrix{Int64}

julia> evolution_history(automaton)
3×3 Matrix{Int64}:
 0  1  0
 1  1  1
 0  0  0
```
"""
@concrete struct CellularAutomaton <: AbstractCellularAutomaton
    generations::Int
    rule
    evolution
end

function CellularAutomaton(
        rule::AbstractCellularAutomatonRule,
        initial_conditions::AbstractVector,
        generations::Integer
    )
    generations >= 1 || throw(ArgumentError("generations must be at least 1"))
    history = rollout(rule, initial_conditions, generations - 1; save = true)
    return CellularAutomaton(Int(generations), rule, permutedims(history))
end

function CellularAutomaton(
        rule::AbstractCellularAutomatonRule,
        initial_conditions::AbstractArray,
        generations::Integer
    )
    generations >= 1 || throw(ArgumentError("generations must be at least 1"))
    evolution = rollout(rule, initial_conditions, generations - 1; save = true)
    return CellularAutomaton(Int(generations), rule, evolution)
end

"""
    cellular_automaton_rule(automaton::AbstractCellularAutomaton)

Return the transition rule used by `automaton`.
"""
cellular_automaton_rule(automaton::CellularAutomaton) = automaton.rule

"""
    evolution_history(automaton::AbstractCellularAutomaton)

Return the retained cellular-automaton evolution.
"""
evolution_history(automaton::CellularAutomaton) = automaton.evolution

"""
    generation_count(automaton::AbstractCellularAutomaton) -> Int

Return the number of generations retained by `automaton`.
"""
generation_count(automaton::CellularAutomaton) = automaton.generations

function Base.show(io::IO, automaton::CellularAutomaton)
    return print(
        io, "CellularAutomaton(", automaton.rule, "; generations=",
        automaton.generations, ")"
    )
end

function Base.show(io::IO, ::MIME"text/plain", automaton::CellularAutomaton)
    println(io, "CellularAutomaton with ", automaton.generations, " generations")
    println(io, "  rule: ", automaton.rule)
    return print(io, "  evolution: ", summary(automaton.evolution))
end
