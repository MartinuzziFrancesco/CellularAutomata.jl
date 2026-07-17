"""
    AbstractLifeLikeCellularAutomatonRule

Supertype for Life-like cellular-automaton rules.
"""
abstract type AbstractLifeLikeCellularAutomatonRule <: AbstractCellularAutomatonRule end

@concrete struct Life <: AbstractLifeLikeCellularAutomatonRule
    born
    survive
    radius::Int
end

spatial_dimensions(::Life) = 2

"""
    Life(life_description; radius=1)

Construct a Life-like cellular-automaton rule using Golly birth/survival notation.

# Arguments

  - `life_description`: `(born, survive)` neighbor counts. `born` contains counts that
    activate a dead cell; `survive` contains counts that preserve a live cell.

# Keyword arguments

  - `radius`: Radius of the square neighborhood. Defaults to 1.

# Examples

```julia
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
function Life(life_description::Tuple; radius::Int=1)
    radius >= 1 || throw(ArgumentError("radius must be at least 1"))
    born, survive = life_description
    return Life(born, survive, radius)
end

function (life::Life)(starting_array::AbstractMatrix)
    return next_state(life, starting_array)
end

function _step(life::Life, state::AbstractMatrix, boundary::AbstractBoundaryCondition)
    return life_evolution(state, life.born, life.survive, life.radius, boundary)
end

function life_evolution(
    starting_array::AbstractMatrix,
    born,
    survive,
    radius::Int,
    boundary::AbstractBoundaryCondition=Periodic(),
)
    return map(CartesianIndices(starting_array)) do index
        row, column = Tuple(index)
        alive = 0
        for column_offset in (-radius):radius, row_offset in (-radius):radius
            if !iszero(row_offset) || !iszero(column_offset)
                alive += Int(
                    _boundary_get(
                        starting_array, boundary, row + row_offset, column + column_offset
                    ),
                )
            end
        end
        current = starting_array[index]
        lives = (isone(current) && alive in survive) || (iszero(current) && alive in born)
        return convert(eltype(starting_array), lives)
    end
end
