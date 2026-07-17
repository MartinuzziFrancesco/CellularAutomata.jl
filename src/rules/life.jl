abstract type AbstractLifeRule <: AbstractTDRule end

@concrete struct Life <: AbstractLifeRule
    born
    survive
    radius::Int
end

"""
    Life(life_description; radius=1)

Create a `Life` object to simulate a cellular automaton based on a variation of
the Conway's Game of Life, using custom rules for cell birth and survival.
The rules are defined using the Golly notation.

# Arguments

  - `life_description`: A tuple of two tuples (`(b, s)`) specifying the birth (`b`)
    and survival (`s`) rules.

      + `b`: A tuple containing the numbers of neighbouring cells that cause a dead
        cell to become alive in the next generation.
      + `s`: A tuple containing the numbers of neighbouring cells that allow a live
        cell to remain alive in the next generation.

  - `radius` (optional): The radius of the neighborhood considered for determining
    cell fate. Defaults to 1.

# Usage

```julia
life = Life(((3,), (2, 3)); radius=1)  # Initializes Life
```

After instantiation, the `Life` object can be used to evolve a given starting
array representing the initial state of the cellular automaton:

```julia
# Initialize Life with custom rules: birth if 3 neighbors, survive if 2 or 3 neighbors
life = Life(((3,), (2, 3)); radius=1)

# Example starting state: a 5x5 grid with a "glider" pattern
starting_array = zeros(Int, 5, 5)
starting_array[2, 3] = 1
starting_array[3, 4] = 1
starting_array[4, 2:4] .= 1

# Compute the next generation
next_generation = life(starting_array)
```
"""
function Life(life_description::Tuple; radius::Int=1)
    born, survive = life_description
    return Life(born, survive, radius)
end

function (life::Life)(starting_array::AbstractMatrix)
    return life_evolution(starting_array, life.born, life.survive, life.radius)
end

function virtual_expansion(starting_array::AbstractMatrix, radius::Int)
    height, width = size(starting_array)
    nh, nw = height - radius + 1, width - radius + 1
    left = vcat(
        starting_array[nh:end, nw:end],
        starting_array[:, nw:end],
        starting_array[1:radius, nw:end],
    )
    right = vcat(
        starting_array[nh:end, 1:radius],
        starting_array[:, 1:radius],
        starting_array[1:radius, 1:radius],
    )
    middle = vcat(starting_array[nh:end, :], starting_array, starting_array[1:radius, :])

    return hcat(left, middle, right)
end

function life_application(neighborhood::AbstractMatrix, born, survive)
    center_i = size(neighborhood, 1) ÷ 2 + 1
    center_j = size(neighborhood, 2) ÷ 2 + 1
    past_value = neighborhood[center_i, center_j]
    alive = sum(neighborhood) - past_value

    if past_value == 1
        return eltype(neighborhood)(alive in survive)
    else
        return eltype(neighborhood)(alive in born)
    end
end

function life_evolution(starting_array::AbstractMatrix, born, survive, radius::Int)
    height, width = size(starting_array)
    output = similar(starting_array)
    expanded = virtual_expansion(starting_array, radius)

    for j in 1:width, i in 1:height
        output[i, j] = life_application(
            expanded[i:(i + 2 * radius), j:(j + 2 * radius)], born, survive
        )
    end
    return output
end
