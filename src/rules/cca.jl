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
function CCA(rule::Real; radius = 1)
    __validate_radius(radius)
    return CCA(rule, radius)
end

function (cca::CCA)(starting_array::AbstractArray)
    return next_state(cca, starting_array)
end

function __step(cca::CCA, cell::AbstractVector, boundary::AbstractBoundaryCondition)
    return __cca_evolution(cell, cca.rule, cca.radius, boundary)
end

__fractional_part(value) = value - floor(value)

@concrete struct __CCAUpdate
    cell
    rule
    boundary
    left
    right
end

function (update::__CCAUpdate)(index)
    indices = (index - update.left):(index + update.right)
    neighborhood = __Neighborhood1D(update.cell, update.boundary, indices)
    return __fractional_part(sum(neighborhood) / length(neighborhood) + update.rule)
end

function __cca_evolution(
        cell::AbstractVector, rule::Real, radius, boundary::AbstractBoundaryCondition = Periodic()
    )
    left, right = __radius_extent(radius)
    return map(__CCAUpdate(cell, rule, boundary, left, right), eachindex(cell))
end

"""
    neighborhood_radius(rule::AbstractCellularAutomatonRule)

Return the spatial neighborhood radius used by `rule`.
"""
neighborhood_radius(cca::CCA) = cca.radius

function Base.show(io::IO, cca::CCA)
    return print(io, "CCA(", cca.rule, "; radius=", cca.radius, ")")
end
