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

```jldoctest
julia> using CellularAutomata

julia> cca = CCA(1 // 10);

julia> next_state(cca, [0 // 1, 0 // 1, 3 // 10])
3-element Vector{Rational{Int64}}:
 1//5
 1//5
 1//5
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

@concrete struct CCAUpdate
    cell
    rule
    boundary
    left
    right
end

function (update::CCAUpdate)(index)
    indices = (index - update.left):(index + update.right)
    neighborhood = Neighborhood1D(update.cell, update.boundary, indices)
    return fractional_part(sum(neighborhood) / length(neighborhood) + update.rule)
end

function cca_evolution(
    cell::AbstractVector, rule::Real, radius, boundary::AbstractBoundaryCondition=Periodic()
)
    left, right = _radius_extent(radius)
    return map(CCAUpdate(cell, rule, boundary, left, right), eachindex(cell))
end
