abstract type AbstractDCARule <: AbstractODRule end

@concrete struct DCA <: AbstractDCARule
    rule
    ruleset
    states::Int
    radius
end

"""
    DCA(rule; states=2, radius=1)

Creates a `DCA` object given a specific rule. It automatically computes the ruleset for
the provided rule, number of states, and radius.

# Arguments

  - `rule`: The rule identifier used for the cellular automaton's evolution.
  - `states` (optional): The number of possible states for each cell. Defaults to 2.
  - `radius` (optional): The neighborhood radius around each cell considered during the
    evolution. Defaults to 1.

# Usage

```julia
dca = DCA(30; states=2, radius=1)  # Creates a DCA with rule 30, 2 states, and radius 1.
```

Once instantiated, the `DCA` object can evolve a given starting array of cell states
through its callable interface:

```julia
dca = DCA(110; states=2, radius=1)  # Initialize with rule 110, 2 states, and a radius of 1
starting_array = [0, 1, 0, 1, 1, 0]  # Initial state
next_generation = dca(starting_array)  # Evolve to the next generation
```
"""
function DCA(rule::Integer; states::Int=2, radius=1)
    ruleset = conversion(rule, states, radius)
    return DCA(rule, ruleset, states, radius)
end

function (dca::DCA)(starting_array::AbstractArray)
    return evolution(starting_array, dca.ruleset, dca.states, dca.radius)
end

function conversion(rule::Integer, states::Int, radius::Int)
    return digits_ruleset(rule, states, states^(2 * radius + 1))
end

function conversion(rule::Integer, states::Int, radius::Tuple)
    return digits_ruleset(rule, states, states^(sum(radius) + 1))
end

digits_ruleset(rule::Integer, states::Int, len::Int) = digits(rule; base=states, pad=len)

function state_reader(neighborhood::AbstractArray, states::Int)
    index = 0
    for cell in neighborhood
        index = index * states + Int(cell)
    end
    return index + 1
end

function evolution(cell::AbstractArray, ruleset, states::Int, radius::Int)
    return evolution(cell, ruleset, states, (radius, radius))
end

function evolution(cell::AbstractArray, ruleset, states::Int, radius::Tuple)
    left, right = radius
    neighborhood_size = left + right + 1
    padded = vcat(cell[(end - left + 1):end], cell, cell[1:right])
    return eltype(cell)[
        ruleset[state_reader(view(padded, i:(i + neighborhood_size - 1)), states)] for
        i in eachindex(cell)
    ]
end
