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

```julia
julia> tca = TCA(102; states=3, radius=1);

julia> next_state(tca, [0, 2, 1, 0, 1, 2])
6-element Vector{Int64}:
 1
 0
 0
 1
 0
 0
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

function tca_evolution(
    cell::AbstractVector, codeset, radius, boundary::AbstractBoundaryCondition=Periodic()
)
    left, right = _radius_extent(radius)
    return map(eachindex(cell)) do i
        neighborhood = Neighborhood1D(cell, boundary, (i - left):(i + right))
        return convert(eltype(cell), codeset[tca_state_reader(neighborhood)])
    end
end
