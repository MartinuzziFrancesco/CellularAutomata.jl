abstract type AbstractCA end

"""
    CellularAutomaton(rule::AbstractODRule, initial_conditions, generations)
    CellularAutomaton(rule::AbstractTDRule, initial_conditions, generations)

Constructs the evolution of a cellular automaton based on a specified rule,
initial conditions, and the number of generations to simulate.
This function supports both one-dimensional (OD) and two-dimensional (TD) cellular automata,
determined by the type of `rule` provided.

# Arguments

  - `rule`: An instance of `AbstractODRule` for one-dimensional cellular automata
    or `AbstractTDRule` for two-dimensional cellular automata. Defines the evolution
    rule for the cellular automaton.
  - `initial_conditions`: An array (for OD) or a matrix (for TD) representing the
    initial state of the cellular automaton.
  - `generations`: The number of generations (or time steps) for which the automaton
    should be evolved.

# Usage

For a one-dimensional cellular automaton:

```julia
rule = DCA(30)  # Define or instantiate a one-dimensional rule
initial_conditions = [0, 1, 0, 1, 1, 0, 1]  # Initial state array
generations = 50  # Number of generations to simulate
automaton_od = CellularAutomaton(rule, initial_conditions, generations)
```

For a two-dimensional cellular automaton:

```julia
rule = Life(((3,), (2, 3)))  # Define or instantiate a two-dimensional rule
initial_conditions = [  # Initial state matrix
    [0, 1, 0],
    [1, 0, 1],
    [0, 1, 0],
]
generations = 50  # Number of generations to simulate
automaton_td = CellularAutomaton(rule, initial_conditions, generations)
```

This function constructs a CellularAutomaton instance that encapsulates the
entire evolution history of the cellular automaton, according to the provided
rule and initial conditions over the specified number of generations.
The exact nature of the evolution—whether it is for a one-dimensional or
two-dimensional automaton—depends on the type of rule supplied.

You can access the evolution by calling the `evolution` field of `CellularAutomaton`

```julia
automaton_td.evolution
```

# Notes

  - The `rule` parameter determines the dimensionality of the cellular automaton.
    Ensure that your `initial_conditions` and `rule` are compatible in terms of dimensions.
"""
struct CellularAutomaton{F,E} <: AbstractCA
    generations::Int
    generation_fun::F
    evolution::E
end

function CellularAutomaton(rule::AbstractODRule, initial_conditions, generations)
    evolution = zeros(
        typeof(initial_conditions[2]), generations, length(initial_conditions)
    )
    evolution[1, :] = initial_conditions

    for i in 2:generations
        evolution[i, :] = rule(evolution[i - 1, :])
    end

    return CellularAutomaton(generations, rule, evolution)
end

function CellularAutomaton(rule::AbstractTDRule, initial_conditions, generations)
    evolution = zeros(
        typeof(initial_conditions[2]),
        size(initial_conditions, 1),
        size(initial_conditions, 2),
        generations,
    )
    evolution[:, :, 1] = initial_conditions

    for i in 2:generations
        evolution[:, :, i] = rule(evolution[:, :, i - 1])
    end

    return CellularAutomaton(generations, rule, evolution)
end