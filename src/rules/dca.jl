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

# Throws

  - `ArgumentError`: If the rule configuration or a transitioned state is outside its
    declared discrete domain.

# Examples

```jldoctest
julia> using CellularAutomata

julia> dca = DCA(30);

julia> rule_lookup_table(dca)
8-element Vector{Int64}:
 0
 1
 1
 1
 1
 0
 0
 0

julia> next_state(dca, [0, 0, 1, 0, 0])
5-element Vector{Int64}:
 0
 1
 1
 1
 0
```
"""
function DCA(rule::Integer; states::Int = 2, radius = 1)
    states >= 2 || throw(ArgumentError("states must be at least 2"))
    __validate_radius(radius)
    ruleset = __conversion(rule, states, radius)
    return DCA(rule, ruleset, states, radius)
end

function (dca::DCA)(starting_array::AbstractArray)
    return next_state(dca, starting_array)
end

__validate_state(dca::DCA, state) = __validate_discrete_state(state, dca.states)

function __step(dca::DCA, cell::AbstractVector, boundary::AbstractBoundaryCondition)
    return __dca_evolution(cell, dca.ruleset, dca.states, dca.radius, boundary)
end

function __conversion(rule::Integer, states::Int, radius)
    left, right = __radius_extent(radius)
    return __digits_ruleset(rule, states, states^(left + right + 1))
end

function __digits_ruleset(rule::Integer, states::Int, len::Int)
    rule >= 0 || throw(ArgumentError("rule must be nonnegative"))
    ruleset = digits(rule; base = states, pad = len)
    length(ruleset) <= len ||
        throw(ArgumentError("rule does not fit the requested states and radius"))
    return ruleset
end

function __state_reader(neighborhood, states::Int)
    index = 0
    for cell in neighborhood
        index = index * states + Int(cell)
    end
    return index + 1
end

@concrete struct __DCAUpdate
    cell
    ruleset
    states
    boundary
    left
    right
end

function (update::__DCAUpdate)(index)
    indices = (index - update.left):(index + update.right)
    neighborhood = __Neighborhood1D(update.cell, update.boundary, indices)
    new_state = update.ruleset[__state_reader(neighborhood, update.states)]
    return convert(eltype(update.cell), new_state)
end

function __dca_evolution(
        cell::AbstractVector,
        ruleset,
        states::Int,
        radius,
        boundary::AbstractBoundaryCondition = Periodic()
    )
    left, right = __radius_extent(radius)
    return map(__DCAUpdate(cell, ruleset, states, boundary, left, right), eachindex(cell))
end

"""
    rule_lookup_table(rule::AbstractDiscreteCellularAutomatonRule)

Return the neighborhood lookup table used by `rule`.
"""
rule_lookup_table(dca::DCA) = dca.ruleset

"""
    cell_state_count(rule::AbstractDiscreteCellularAutomatonRule) -> Int

Return the number of possible cell states supported by `rule`.
"""
cell_state_count(dca::DCA) = dca.states

neighborhood_radius(dca::DCA) = dca.radius

function Base.show(io::IO, dca::DCA)
    return print(
        io, "DCA(", dca.rule, "; states=", dca.states, ", radius=", dca.radius, ")"
    )
end
