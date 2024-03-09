
abstract type AbstractLifeRule <: AbstractTDRule end

struct Life{T,A,C} <: AbstractLifeRule
    born::T
    survive::A
    radius::C
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
starting_array[4, 2:4] = 1

# Compute the next generation
next_generation = life(starting_array)
```
"""
function Life(life_description; radius=1)
    born, survive = life_description[1], life_description[2]
    return Life(born, survive, radius)
end

function (life::Life)(starting_array)
    return nextgen = life_evolution(starting_array, life.born, life.survive, life.radius)
end

function virtual_expansion(starting_array, radius)
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

function life_application(state, born, survive)
    past_value = state[size(state, 1) ÷ 2 + 1, size(state, 2) ÷ 2 + 1] #save past cell value
    state[size(state, 1) ÷ 2 + 1, size(state, 2) ÷ 2 + 1] = 0 #past cell value set to zero
    alive = sum(state) #the sum is the number of cell alive in the neighborhood since the central value is equal to zero

    if past_value == 1 && alive in survive
        return 1
    elseif past_value == 0 && alive in born
        return 1
    else
        return 0
    end
end

function life_evolution(starting_array, born, survive, radius)
    height, width = size(starting_array)
    output = zeros(typeof(starting_array[2]), height, width)
    virtual_output = virtual_expansion(starting_array, radius)

    for i in 1:(height - radius + 1), j in 1:(width - radius + 1)
        output[i, j] = life_application(
            virtual_output[i:(i + radius + 1), j:(j + radius + 1)], born, survive
        )
    end
    return output
end
