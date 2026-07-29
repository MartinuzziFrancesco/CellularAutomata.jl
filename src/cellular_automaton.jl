"""
    AbstractCellularAutomaton

Supertype for cellular automata that retain an evolution history.
"""
abstract type AbstractCellularAutomaton end

"""
    next_state(rule, state; boundary=Periodic())

Apply one synchronous cellular-automaton transition without mutating `state`.
Rules may specialize this function to define differentiable transitions.

# Arguments

  - `rule`: Cellular-automaton transition rule.
  - `state`: Current state array.

# Keyword arguments

  - `boundary`: Boundary condition used outside the state array.
    Defaults to `Periodic()`.

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
        boundary::AbstractBoundaryCondition = Periodic()
    )
    __validate_state(rule, state)
    return __step(rule, state, boundary)
end

@concrete struct __Transition
    rule
    boundary
end

function (transition::__Transition)(state, _)
    return next_state(transition.rule, state; boundary = transition.boundary)
end

"""
    rollout(rule, initial_state, steps; boundary=Periodic(), save=false)

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
        save::Bool = false
    )
    steps >= 0 || throw(ArgumentError("steps must be nonnegative"))
    isempty(initial_state) && throw(ArgumentError("initial_state cannot be empty"))
    transition = __Transition(rule, boundary)
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
