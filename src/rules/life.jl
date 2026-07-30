"""
    AbstractLifeLikeCellularAutomatonRule

Supertype for Life-like cellular-automaton rules.
"""
abstract type AbstractLifeLikeCellularAutomatonRule <: AbstractCellularAutomatonRule end

@concrete struct Life <: AbstractLifeLikeCellularAutomatonRule
    born
    survive
    neighborhood
end

spatial_dimensions(::Life) = 2

"""
    Life(life_description; radius=1, neighborhood=Moore(radius))

Construct a Life-like cellular-automaton rule using Golly birth/survival notation.

# Arguments

  - `life_description`: `(born, survive)` neighbor counts. `born` contains counts that
    activate a dead cell; `survive` contains counts that preserve a live cell.

# Keyword arguments

  - `radius`: Radius of the default [`Moore`](@ref) neighborhood. Defaults to 1. Ignored
    if `neighborhood` is passed explicitly.
  - `neighborhood`: An [`AbstractNeighborhood`](@ref), such as `Moore(radius)` (default)
    or `VonNeumann(radius)`.

# Examples

```jldoctest
julia> using CellularAutomata

julia> life = Life(((3,), (2, 3)); radius=1);

julia> blinker = [0 0 0 0 0; 0 0 1 0 0; 0 0 1 0 0; 0 0 1 0 0; 0 0 0 0 0];

julia> next_state(life, blinker)
5×5 Matrix{Int64}:
 0  0  0  0  0
 0  0  0  0  0
 0  1  1  1  0
 0  0  0  0  0
 0  0  0  0  0
```
"""
function Life(
        life_description::Tuple; radius::Int = 1,
        neighborhood::AbstractNeighborhood = Moore(radius)
    )
    neighborhood_radius(neighborhood) >= 1 ||
        throw(ArgumentError("neighborhood radius must be at least 1"))
    born, survive = life_description
    return Life(born, survive, neighborhood)
end

function (life::Life)(starting_array::AbstractMatrix)
    return next_state(life, starting_array)
end

function __step(life::Life, state::AbstractMatrix, boundary::AbstractBoundaryCondition)
    return __life_evolution(state, life.born, life.survive, life.neighborhood, boundary)
end

@concrete struct __LifeUpdate
    state
    born
    survive
    neighborhood
    boundary
end

function (update::__LifeUpdate)(index::CartesianIndex{2})
    row, column = Tuple(index)
    alive = 0
    for (row_offset, column_offset) in neighborhood_offsets(update.neighborhood)
        alive += Int(
            __boundary_get(
                update.state, update.boundary, row + row_offset, column + column_offset
            ),
        )
    end
    current = update.state[index]
    lives = (isone(current) && alive in update.survive) ||
        (iszero(current) && alive in update.born)
    return convert(eltype(update.state), lives)
end

function __life_evolution(
        starting_array::AbstractMatrix,
        born,
        survive,
        neighborhood::AbstractNeighborhood,
        boundary::AbstractBoundaryCondition = Periodic()
    )
    update = __LifeUpdate(starting_array, born, survive, neighborhood, boundary)
    return map(update, CartesianIndices(starting_array))
end

neighborhood_radius(life::Life) = neighborhood_radius(life.neighborhood)

function Base.show(io::IO, life::Life)
    if life.neighborhood isa Moore
        return print(
            io, "Life(", (life.born, life.survive), "; radius=",
            neighborhood_radius(life.neighborhood), ")"
        )
    end
    return print(
        io, "Life(", (life.born, life.survive), "; neighborhood=", life.neighborhood, ")"
    )
end
