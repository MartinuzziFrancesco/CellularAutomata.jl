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

```julia
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
    boundary::AbstractBoundaryCondition=Periodic(),
)
    return _step(rule, state, boundary)
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

```julia
julia> history = rollout(DCA(30), [0, 0, 1, 0, 0], 2; save=true);

julia> size(history)
(5, 3)
```
"""
function rollout(
    rule::AbstractCellularAutomatonRule,
    initial_state,
    steps::Integer;
    boundary::AbstractBoundaryCondition=Periodic(),
    save::Bool=false,
)
    steps >= 0 || throw(ArgumentError("steps must be nonnegative"))
    isempty(initial_state) && throw(ArgumentError("initial_state cannot be empty"))
    transition = (state, _) -> next_state(rule, state; boundary=boundary)
    if save
        states = accumulate(transition, 1:steps; init=initial_state)
        return stack(Iterators.flatten(((initial_state,), states)))
    end
    return foldl(transition, 1:steps; init=initial_state)
end

"""
    CellularAutomaton(rule, initial_conditions, generations)

Construct a cellular automaton and retain its complete evolution history. For vector
states, `evolution` stores time on the first axis. For higher-dimensional states,
time is stored on the last axis.

# Arguments

  - `rule`: Cellular-automaton rule defining one transition.
  - `initial_conditions`: Initial state array.
  - `generations`: Number of retained generations, including the initial state.

# Examples

```julia
julia> automaton = CellularAutomaton(DCA(30), [0, 1, 0], 3);

julia> automaton.evolution
3×3 Matrix{Int64}:
 0  1  0
 1  1  1
 0  0  0
```
"""
@concrete struct CellularAutomaton <: AbstractCellularAutomaton
    generations::Int
    generation_fun
    evolution
end

function CellularAutomaton(
    rule::AbstractCellularAutomatonRule,
    initial_conditions::AbstractVector,
    generations::Integer,
)
    generations >= 1 || throw(ArgumentError("generations must be at least 1"))
    history = rollout(rule, initial_conditions, generations - 1; save=true)
    return CellularAutomaton(Int(generations), rule, permutedims(history))
end

function CellularAutomaton(
    rule::AbstractCellularAutomatonRule,
    initial_conditions::AbstractArray,
    generations::Integer,
)
    generations >= 1 || throw(ArgumentError("generations must be at least 1"))
    evolution = rollout(rule, initial_conditions, generations - 1; save=true)
    return CellularAutomaton(Int(generations), rule, evolution)
end
