abstract type AbstractDCARule <: AbstractODRule end

struct DCA{B,R,T} <: AbstractDCARule
    rule::B
    ruleset::R
    states::Int
    radius::T
end

"""
    DCA(rule; states=2, radius=1)

Creates a `DCA` object given a specific rule. It automatically computes the ruleset for
the provided rule, number of states, and radius.

# Arguments

  - `rule`: The rule identifier used for the cellular automaton's evolution.
  - `states` (optional): The number of possible states for each cell. Defaults to 2.
  - `radius` (optional): The neighborhood radius around each cell considered during the
    evolution. Defaults to 1.

# Usage

```julia
dca = DCA(30; states=2, radius=1)  # Creates a DCA with rule 30, 2 states, and radius 1.
```

Once instantiated, the `DCA` object can evolve a given starting array of cell states
through its callable interface:

```julia
dca = DCA(110; states=2, radius=1)  # Initialize with rule 110, 2 states, and a radius of 1
starting_array = [0, 1, 0, 1, 1, 0]  # Initial state
next_generation = dca(starting_array)  # Evolve to the next generation
```
"""
function DCA(rule; states=2, radius=1)
    ruleset = conversion(rule, states, radius)
    return DCA(rule, ruleset, states, radius)
end

function (dca::DCA)(starting_array)
    return nextgen = evolution(starting_array, dca.ruleset, dca.states, dca.radius)
end

function conversion(rule, states, radius::Int)
    rule_len = states^(2 * radius + 1)
    rule_bin = parse.(Int, split(string(rule; base=states), ""))
    rule_bin = vcat(zeros(typeof(rule_bin[1]), rule_len - length(rule_bin)), rule_bin)
    return reverse!(rule_bin)
end

function conversion(rule, states, radius::Tuple)
    rule_len = states^(sum(radius) + 1)
    rule_bin = parse.(Int, split(string(rule; base=states), ""))
    rule_bin = vcat(zeros(typeof(rule_bin[1]), rule_len - length(rule_bin)), rule_bin)
    return reverse!(rule_bin)
end

function state_reader(neighborhood, states)
    return parse(Int, join(convert(Array{Int}, neighborhood)); base=states) + 1 #ugly
end

function evolution(cell, ruleset, states, radius::Int)
    neighborhood_size = radius * 2 + 1
    output = zeros(length(cell))
    cell = vcat(
        cell[(end - neighborhood_size ÷ 2 + 1):end], cell, cell[1:(neighborhood_size ÷ 2)]
    )

    for i in 1:(length(cell) - neighborhood_size + 1)
        output[i] = ruleset[state_reader(cell[i:(i + neighborhood_size - 1)], states)]
    end

    return output
end

function evolution(cell, ruleset, states, radius::Tuple)
    neighborhood_size = sum(radius) + 1
    output = zeros(length(cell))#da qui in poi da modificare
    cell = vcat(cell[(end - radius[1] + 1):end], cell, cell[1:radius[2]])

    for i in 1:(length(cell) - neighborhood_size + 1)
        output[i] = ruleset[state_reader(cell[i:(i + neighborhood_size - 1)], states)]
    end

    return output
end
