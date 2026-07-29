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

# Throws

  - `ArgumentError`: If the rule configuration or a transitioned state is outside its
    declared discrete domain.

# Examples

```jldoctest
julia> using CellularAutomata

julia> tca = TCA(3);

julia> rule_lookup_table(tca)
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
function TCA(code::Integer; states::Int = 2, radius = 1)
    states >= 2 || throw(ArgumentError("states must be at least 2"))
    __validate_radius(radius)
    codeset = __tca_conversion(code, states, radius)
    return TCA(code, codeset, states, radius)
end

function (tca::TCA)(starting_array::AbstractArray)
    return next_state(tca, starting_array)
end

__validate_state(tca::TCA, state) = __validate_discrete_state(state, tca.states)

function __step(tca::TCA, cell::AbstractVector, boundary::AbstractBoundaryCondition)
    return __tca_evolution(cell, tca.codeset, tca.radius, boundary)
end

function __tca_conversion(code::Integer, states::Int, radius)
    left, right = __radius_extent(radius)
    return __digits_ruleset(code, states, (states - 1) * (left + right + 1) + 1)
end

__tca_state_reader(neighborhood) = Int(sum(neighborhood)) + 1

@concrete struct __TCAUpdate
    cell
    codeset
    boundary
    left
    right
end

function (update::__TCAUpdate)(index)
    indices = (index - update.left):(index + update.right)
    neighborhood = __Neighborhood1D(update.cell, update.boundary, indices)
    new_state = update.codeset[__tca_state_reader(neighborhood)]
    return convert(eltype(update.cell), new_state)
end

function __tca_evolution(
        cell::AbstractVector, codeset, radius, boundary::AbstractBoundaryCondition = Periodic()
    )
    left, right = __radius_extent(radius)
    return map(__TCAUpdate(cell, codeset, boundary, left, right), eachindex(cell))
end

rule_lookup_table(tca::TCA) = tca.codeset
cell_state_count(tca::TCA) = tca.states
neighborhood_radius(tca::TCA) = tca.radius

function Base.show(io::IO, tca::TCA)
    return print(
        io, "TCA(", tca.code, "; states=", tca.states, ", radius=", tca.radius, ")"
    )
end
