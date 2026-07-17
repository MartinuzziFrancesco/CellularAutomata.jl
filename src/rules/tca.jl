"""
    AbstractTotalisticCellularAutomatonRule

Supertype for rules whose transitions depend on the total neighborhood state.
"""
abstract type AbstractTotalisticCellularAutomatonRule <:
              AbstractDiscreteCellularAutomatonRule end

@concrete struct TCA <: AbstractTotalisticCellularAutomatonRule
    code
    codeset
    states::Int
    radius
end

spatial_dimensions(::TCA) = 1

"""
    TCA(code; states=2, radius=1)

Construct a totalistic cellular-automaton rule and its lookup table.

# Arguments

  - `code`: Nonnegative totalistic rule identifier.

# Keyword arguments

  - `states`: Number of possible cell states. Defaults to 2.
  - `radius`: Symmetric radius or `(left, right)` asymmetric radius. Defaults to 1.

# Examples

```jldoctest
julia> using CellularAutomata

julia> tca = TCA(3);

julia> tca.codeset
4-element Vector{Int64}:
 1
 1
 0
 0

julia> next_state(tca, [0, 0, 1, 0, 0])
5-element Vector{Int64}:
 1
 1
 1
 1
 1
```
"""
function TCA(code::Integer; states::Int=2, radius=1)
    states >= 2 || throw(ArgumentError("states must be at least 2"))
    _validate_radius(radius)
    codeset = tca_conversion(code, states, radius)
    return TCA(code, codeset, states, radius)
end

function (tca::TCA)(starting_array::AbstractArray)
    return next_state(tca, starting_array)
end

function _step(tca::TCA, cell::AbstractVector, boundary::AbstractBoundaryCondition)
    return tca_evolution(cell, tca.codeset, tca.radius, boundary)
end

function tca_conversion(code::Integer, states::Int, radius)
    left, right = _radius_extent(radius)
    return digits_ruleset(code, states, (states - 1) * (left + right + 1) + 1)
end

tca_state_reader(neighborhood) = Int(sum(neighborhood)) + 1

@concrete struct TCAUpdate
    cell
    codeset
    boundary
    left
    right
end

function (update::TCAUpdate)(index)
    indices = (index - update.left):(index + update.right)
    neighborhood = Neighborhood1D(update.cell, update.boundary, indices)
    new_state = update.codeset[tca_state_reader(neighborhood)]
    return convert(eltype(update.cell), new_state)
end

function tca_evolution(
        cell::AbstractVector, codeset, radius, boundary::AbstractBoundaryCondition=Periodic()
)
    left, right = _radius_extent(radius)
    return map(TCAUpdate(cell, codeset, boundary, left, right), eachindex(cell))
end
