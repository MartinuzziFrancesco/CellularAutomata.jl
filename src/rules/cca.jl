abstract type AbstractCCARule <: AbstractODRule end

struct CCA{T<:Real} <: AbstractCCARule
    rule::T
    radius::Int
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
function CCA(rule::T; radius=1) where {T<:Real}
    return CCA(rule, radius)
end

function (cca::CCA)(starting_array::AbstractArray)
    return nextgen = evolution(starting_array, cca.rule, cca.radius)
end

function c_state_reader(neighborhood::AbstractArray, radius)
    return sum(neighborhood) / length(neighborhood)
end

function evolution(cell::AbstractArray, rule::T, radius::Number) where {T<:Real}
    neighborhood_size = radius * 2 + 1
    output = zeros(length(cell))
    cell = vcat(
        cell[(end - neighborhood_size ÷ 2 + 1):end], cell, cell[1:(neighborhood_size ÷ 2)]
    )

    for i in 1:(length(cell) - neighborhood_size + 1)
        output[i] = modf(
            c_state_reader(cell[i:(i + neighborhood_size - 1)], radius) + rule
        )[1]
    end

    return output
end

function evolution(cell::AbstractArray, rule::T, radius::Tuple) where {T<:Real}
    neighborhood_size = sum(radius) + 1
    output = zeros(length(cell))
    cell = vcat(
        cell[(end - neighborhood_size ÷ 2 + 1):end], cell, cell[1:(neighborhood_size ÷ 2)]
    )

    for i in 1:(length(cell) - neighborhood_size + 1)
        output[i] = modf(
            c_state_reader(cell[i:(i + neighborhood_size - 1)], radius) + rule
        )[1]
    end

    return output
end
