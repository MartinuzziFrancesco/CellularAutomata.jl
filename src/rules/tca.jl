abstract type AbstractTCARule <: AbstractDCARule end

struct TCA{B,R,T} <: AbstractTCARule
    code::B
    codeset::R
    states::Int
    radius::T
end

"""
    TCA(code; states=2, radius=1)

Constructs a Totalistic Cellular Automaton (TCA) with a specified code, number of states,
and neighborhood radius. It automatically computes the codeset for the provided code
and configuration, which is used for the automaton's evolution.

# Arguments

  - `code`: An integer or string representing the rule code for the automaton's evolution.
  - `states` (optional): The number of possible states for each cell. Defaults to 2.
  - `radius` (optional): The neighborhood radius around each cell considered during the
    evolution. Defaults to 1.

# Usage

```julia
tca = TCA(30; states=2, radius=1)  # Creates a TCA with rule code 30, 2 states, and radius 1.
```

After instantiation, the `TCA` object can be used to evolve a given starting array of
cell states:

```julia
# Initialize TCA with a specific code, default states, and radius
tca = TCA(102; states=3, radius=1)

# Example starting state: a 1D array of cells
starting_array = [0, 2, 1, 0, 1, 2]

# Compute the next generation
next_generation = tca(starting_array)
```
"""
function TCA(code; states=2, radius=1)
    codeset = tca_conversion(code, states, radius)
    return TCA(code, codeset, states, radius)
end

function (tca::TCA)(starting_array::AbstractArray)
    return nextgen = tca_evolution(starting_array, tca.codeset, tca.states, tca.radius)
end

function tca_conversion(code, states, radius::Number)
    code_len = (2 * radius + 1) * states - 2
    code_bin = parse.(Int, split(string(code; base=states), ""))
    code_bin = vcat(zeros(typeof(code_bin[1]), code_len - length(code_bin)), code_bin)
    return reverse!(code_bin)
end

function tca_conversion(code, states, radius::Tuple)
    code_len = (sum(radius) + 1) * states - 2
    code_bin = parse.(Int, split(string(code; base=states), ""))
    code_bin = vcat(zeros(typeof(code_bin[1]), code_len - length(code_bin)), code_bin)
    return reverse!(code_bin)
end

function tca_state_reader(neighborhood::AbstractArray, codeset_len)
    return mod1(sum(neighborhood) + 1, codeset_len)
end

function tca_evolution(cell::AbstractArray, codeset, states, radius::Number)
    neighborhood_size = radius * 2 + 1
    output = zeros(length(cell))
    cell = vcat(
        cell[(end - neighborhood_size ÷ 2 + 1):end], cell, cell[1:(neighborhood_size ÷ 2)]
    )

    for i in 1:(length(cell) - neighborhood_size + 1)
        output[i] = codeset[tca_state_reader(
            cell[i:(i + neighborhood_size - 1)], length(codeset)
        )]
    end

    return output
end

function tca_evolution(cell::AbstractArray, codeset, states, radius::Tuple)
    neighborhood_size = sum(radius) + 1
    output = zeros(length(cell))
    cell = vcat(cell[(end - radius[1] + 1):end], cell, cell[1:radius[2]])

    for i in 1:(length(cell) - neighborhood_size + 1)
        output[i] = codeset[tca_state_reader(
            cell[i:(i + neighborhood_size - 1)], length(codeset)
        )]
    end

    return output
end
