"""
    AbstractDiscreteCellularAutomatonRule

Supertype for cellular-automaton rules based on discrete neighborhood lookup tables.
"""
abstract type AbstractDiscreteCellularAutomatonRule <: AbstractCellularAutomatonRule end

@concrete struct DCA <: AbstractDiscreteCellularAutomatonRule
    rule
    ruleset
    states::Int
    radius
end

spatial_dimensions(::DCA) = 1

"""
    DCA(rule; states=2, radius=1)

Construct a discrete cellular-automaton rule and its neighborhood lookup table.

# Arguments

  - `rule`: Nonnegative Wolfram rule identifier.

# Keyword arguments

  - `states`: Number of possible cell states. Defaults to 2.
  - `radius`: Symmetric radius or `(left, right)` asymmetric radius. Defaults to 1.

# Examples

```julia
julia> dca = DCA(110; states=2, radius=1);

julia> next_state(dca, [0, 1, 0, 1, 1, 0])
6-element Vector{Int64}:
 1
 1
 1
 1
 1
 0
```
"""
function DCA(rule::Integer; states::Int=2, radius=1)
    states >= 2 || throw(ArgumentError("states must be at least 2"))
    _validate_radius(radius)
    ruleset = conversion(rule, states, radius)
    return DCA(rule, ruleset, states, radius)
end

function (dca::DCA)(starting_array::AbstractArray)
    return next_state(dca, starting_array)
end

function _step(dca::DCA, cell::AbstractVector, boundary::AbstractBoundaryCondition)
    return dca_evolution(cell, dca.ruleset, dca.states, dca.radius, boundary)
end

function conversion(rule::Integer, states::Int, radius)
    left, right = _radius_extent(radius)
    return digits_ruleset(rule, states, states^(left + right + 1))
end

function digits_ruleset(rule::Integer, states::Int, len::Int)
    rule >= 0 || throw(ArgumentError("rule must be nonnegative"))
    ruleset = digits(rule; base=states, pad=len)
    length(ruleset) <= len ||
        throw(ArgumentError("rule does not fit the requested states and radius"))
    return ruleset
end

function state_reader(neighborhood, states::Int)
    index = 0
    for cell in neighborhood
        index = index * states + Int(cell)
    end
    return index + 1
end

function dca_evolution(
    cell::AbstractVector,
    ruleset,
    states::Int,
    radius,
    boundary::AbstractBoundaryCondition=Periodic(),
)
    left, right = _radius_extent(radius)
    return map(eachindex(cell)) do i
        neighborhood = Neighborhood1D(cell, boundary, (i - left):(i + right))
        return convert(eltype(cell), ruleset[state_reader(neighborhood, states)])
    end
end
