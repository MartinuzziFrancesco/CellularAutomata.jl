"""
    AbstractContinuousCellularAutomatonRule

Supertype for cellular-automaton rules with continuous cell states.
"""
abstract type AbstractContinuousCellularAutomatonRule <: AbstractCellularAutomatonRule end

@concrete struct CCA <: AbstractContinuousCellularAutomatonRule
    rule
    radius
end

spatial_dimensions(::CCA) = 1

"""
    CCA(rule; radius=1)

Construct a continuous cellular-automaton rule. Each output is the fractional part
of the neighborhood mean plus `rule`.

# Arguments

  - `rule`: Value added to each neighborhood mean.

# Keyword arguments

  - `radius`: Symmetric radius or `(left, right)` asymmetric radius. Defaults to 1.

# Examples

```julia
julia> cca = CCA(0.45; radius=1);

julia> next_state(cca, [0.0, 1.0, 0.0, 1.0, 0.5, 1.0])
6-element Vector{Float64}:
 0.7833333333333333
 0.7833333333333333
 0.11666666666666664
 0.95
 0.2833333333333333
 0.95
```
"""
function CCA(rule::Real; radius=1)
    _validate_radius(radius)
    return CCA(rule, radius)
end

function (cca::CCA)(starting_array::AbstractArray)
    return next_state(cca, starting_array)
end

function _step(cca::CCA, cell::AbstractVector, boundary::AbstractBoundaryCondition)
    return cca_evolution(cell, cca.rule, cca.radius, boundary)
end

fractional_part(value) = value - floor(value)

function cca_evolution(
    cell::AbstractVector, rule::Real, radius, boundary::AbstractBoundaryCondition=Periodic()
)
    left, right = _radius_extent(radius)
    neighborhood_size = left + right + 1
    return map(eachindex(cell)) do i
        neighborhood = Neighborhood1D(cell, boundary, (i - left):(i + right))
        return fractional_part(sum(neighborhood) / neighborhood_size + rule)
    end
end
