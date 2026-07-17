abstract type AbstractTCARule <: AbstractDCARule end

@concrete struct TCA <: AbstractTCARule
    code
    codeset
    states::Int
    radius
end

"""
    TCA(code; states=2, radius=1)

Constructs a Totalistic Cellular Automaton (TCA) with a specified code, number of states,
and neighborhood radius. It automatically computes the codeset for the provided code
and configuration, which is used for the automaton's evolution.

# Arguments

  - `code`: An integer representing the rule code for the automaton's evolution.
  - `states` (optional): The number of possible states for each cell. Defaults to 2.
  - `radius` (optional): The neighborhood radius around each cell considered during the
    evolution. Defaults to 1.

# Usage

```julia
tca = TCA(30; states=2, radius=1)  # Creates a TCA with rule code 30, 2 states, and radius 1.
```

After instantiation, the `TCA` object can be used to evolve a given starting array of
cell states:

```julia
# Initialize TCA with a specific code, default states, and radius
tca = TCA(102; states=3, radius=1)

# Example starting state: a 1D array of cells
starting_array = [0, 2, 1, 0, 1, 2]

# Compute the next generation
next_generation = tca(starting_array)
```
"""
function TCA(code::Integer; states::Int=2, radius=1)
    codeset = tca_conversion(code, states, radius)
    return TCA(code, codeset, states, radius)
end

function (tca::TCA)(starting_array::AbstractArray)
    return tca_evolution(starting_array, tca.codeset, tca.states, tca.radius)
end

function tca_conversion(code::Integer, states::Int, radius::Int)
    return digits_ruleset(code, states, (states - 1) * (2 * radius + 1) + 1)
end

function tca_conversion(code::Integer, states::Int, radius::Tuple)
    return digits_ruleset(code, states, (states - 1) * (sum(radius) + 1) + 1)
end

tca_state_reader(neighborhood::AbstractArray) = Int(sum(neighborhood)) + 1

function tca_evolution(cell::AbstractArray, codeset, states::Int, radius::Int)
    return tca_evolution(cell, codeset, states, (radius, radius))
end

function tca_evolution(cell::AbstractArray, codeset, states::Int, radius::Tuple)
    left, right = radius
    neighborhood_size = left + right + 1
    padded = vcat(cell[(end - left + 1):end], cell, cell[1:right])
    return eltype(cell)[
        codeset[tca_state_reader(view(padded, i:(i + neighborhood_size - 1)))] for
        i in eachindex(cell)
    ]
end
