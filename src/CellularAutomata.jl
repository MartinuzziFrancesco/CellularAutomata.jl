module CellularAutomata

abstract type AbstractCA end

struct CellularAutomaton{F,E} <: AbstractCA
    generations::Int
    generation_fun::F
    evolution::E
end


"""
    CellularAutomaton(rule::AbstractODRule, initial_conditions, generations)
    CellularAutomaton(rule::AbstractTDRule, initial_conditions, generations)

Given a cellular automata rule (inluded in the library or provided by the user) returns a CellularAutomaton evolution
with given initial conditions and number of generations. OD indicates one-diomensional cellular automata rules, TD
indicates two-dimensiona cellular automata rules.
"""
function CellularAutomaton(rule, initial_conditions, generations)

    evolution = zeros(typeof(initial_conditions[2]), size(initial_conditions, 1), size(initial_conditions, 2), generations)
    evolution[:, :, 1] = initial_conditions

    for i=2:generations
        evolution[:, :, i] = rule(evolution[:, :, i-1])
    end

    if 1 in size(evolution)
        f, s, t = size(evolution)
        f == 1 ? array_dim = s : array_dim = f
        evolution = reshape(evolution, generations, array_dim)
    end

    CellularAutomaton(generations, rule, evolution)

end

export CellularAutomaton

include("dca.jl")
export DCA, ECA
include("cca.jl")
export CCA
include("tca.jl")
export TCA

include("life.jl")
export Life

include("measures.jl")
export lempel_ziv

end # module
