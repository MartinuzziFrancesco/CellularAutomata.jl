"""
    AbstractCellularAutomatonRule

Supertype for cellular-automaton transition rules. Subtypes must implement
`_step(rule, state, boundary)` returning the next state without mutating `state`,
or specialize [`next_state`](@ref) directly.
"""
abstract type AbstractCellularAutomatonRule end

"""
    AbstractBoundaryCondition

Supertype for boundary conditions used when neighborhoods cross state-array edges.
"""
abstract type AbstractBoundaryCondition end

"""
    Periodic()

Wrap indices around the opposite edge of the state array.

# Examples

```jldoctest
julia> using CellularAutomata

julia> next_state(CCA(0 // 1), [0 // 1, 0 // 1, 3 // 10]; boundary=Periodic())
3-element Vector{Rational{Int64}}:
 1//10
 1//10
 1//10
```
"""
struct Periodic <: AbstractBoundaryCondition end

"""
    Reflecting()

Mirror indices at the edge of the state array.

# Examples

```jldoctest
julia> using CellularAutomata

julia> next_state(CCA(0 // 1), [0 // 1, 0 // 1, 3 // 10]; boundary=Reflecting())
3-element Vector{Rational{Int64}}:
  0
 1//10
 1//10
```
"""
struct Reflecting <: AbstractBoundaryCondition end

"""
    ConstantBoundary([value = 0])

Use `value` for indices outside the state array.

# Examples

```jldoctest
julia> using CellularAutomata

julia> next_state(CCA(0 // 1), [0 // 1, 0 // 1, 3 // 10]; boundary=ConstantBoundary())
3-element Vector{Rational{Int64}}:
  0
 1//10
 1//10
```
"""
@concrete struct ConstantBoundary <: AbstractBoundaryCondition
    value
end

ConstantBoundary() = ConstantBoundary(0)

@inline _boundary_index(i, n, ::Periodic) = mod1(i, n)
@inline function _boundary_index(i, n, ::Reflecting)
    n == 1 && return 1
    reflected = mod(i - 1, 2n - 2) + 1
    return reflected <= n ? reflected : 2n - reflected
end

@inline function _boundary_get(array, boundary::Union{Periodic, Reflecting}, i)
    return array[_boundary_index(i, length(array), boundary)]
end
@inline function _boundary_get(array, boundary::Union{Periodic, Reflecting}, i, j)
    row = _boundary_index(i, size(array, 1), boundary)
    column = _boundary_index(j, size(array, 2), boundary)
    return array[row, column]
end
@inline function _boundary_get(array, boundary::ConstantBoundary, i)
    return checkbounds(Bool, array, i) ? array[i] : boundary.value
end
@inline function _boundary_get(array, boundary::ConstantBoundary, i, j)
    return checkbounds(Bool, array, i, j) ? array[i, j] : boundary.value
end

@concrete struct Neighborhood1D
    array
    boundary
    indices
end

Base.length(neighborhood::Neighborhood1D) = length(neighborhood.indices)
Base.IteratorSize(::Type{<:Neighborhood1D}) = Base.HasLength()
function Base.iterate(neighborhood::Neighborhood1D, state...)
    iteration = iterate(neighborhood.indices, state...)
    isnothing(iteration) && return nothing
    index, next_iteration = iteration
    return _boundary_get(neighborhood.array, neighborhood.boundary, index), next_iteration
end

_radius_extent(radius::Integer) = (radius, radius)
_radius_extent(radius::Tuple{<:Integer, <:Integer}) = radius

function _validate_radius(radius)
    left, right = _radius_extent(radius)
    if left < 0 || right < 0
        throw(ArgumentError("radius must be nonnegative"))
    end
    return nothing
end

"""
    spatial_dimensions(rule)

Return the number of spatial dimensions used by a cellular-automaton rule. State arrays
may have additional channel or batch dimensions.

# Examples

```jldoctest
julia> using CellularAutomata

julia> spatial_dimensions(DCA(30))
1

julia> spatial_dimensions(Life(((3,), (2, 3))))
2
```
"""
function spatial_dimensions end
