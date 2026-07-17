abstract type AbstractCCARule <: AbstractODRule end

@concrete struct CCA <: AbstractCCARule
    rule
    radius
end

"""
    CCA(rule; radius=1)

Create a Continuous Cellular Automaton (CCA) object.

# Arguments

  - `rule`: A numeric code defining the evolution rule for the cellular automaton.
  - `radius` (optional): The radius of the neighborhood around each cell considered
    for its update at each step. Defaults to `1`.

# Returns

`CCA`: A `CCA` object initialized with the given rule and radius.

# Examples

```julia
cca = CCA(0.5)
```

Once created, the `CCA` object can be used to evolve a given starting array of cell states:

```julia
cca = CCA(0.45; radius=1)  # Initialize with rule 0.45 and default radius
starting_array = [0, 1, 0, 1, 0.5, 1]  # Initial state
next_generation = cca(starting_array)  # Evolve to next generation
```

The evolution is determined by the rule applied to the sum of the neighborhood states,
normalized by their count, for each cell in the array.
"""
function CCA(rule::Real; radius=1)
    return CCA(rule, radius)
end

function (cca::CCA)(starting_array::AbstractArray)
    return evolution(starting_array, cca.rule, cca.radius)
end

fractional_part(value) = value - floor(value)

function evolution(cell::AbstractArray, rule::Real, radius::Int)
    return evolution(cell, rule, (radius, radius))
end

function evolution(cell::AbstractArray, rule::Real, radius::Tuple)
    left, right = radius
    neighborhood_size = left + right + 1
    padded = vcat(cell[(end - left + 1):end], cell, cell[1:right])
    return [
        fractional_part(
            sum(view(padded, i:(i + neighborhood_size - 1))) / neighborhood_size + rule
        ) for i in eachindex(cell)
    ]
end
