module CellularAutomata

abstract type AbstractRule end
abstract type AbstractODRule <: AbstractRule end
abstract type AbstractTDRule <: AbstractRule end
abstract type AbstractCA end

struct CellularAutomaton{F,E} <: AbstractCA
    generations::Int
    generation_fun::F
    evolution::E
end


"""
    CellularAutomaton(rule::AbstractODRule, initial_conditions, generations)
    CellularAutomaton(rule::AbstractTDRule, initial_conditions, generations)

Given a cellular automata rule (inluded in the library of provided by the user) returns a CellularAutomaton evolution
with given initial conditions and number of generations. OD indicates one-diomensional cellular automata rules, TD
indicates two-dimensiona cellular automata rules.
"""

function CellularAutomaton(rule::AbstractODRule, initial_conditions, generations)

    evolution = zeros(typeof(initial_conditions[2]), generations, length(initial_conditions))
    evolution[1,:] = initial_conditions

    for i=2:generations
        evolution[i,:] = rule(evolution[i-1,:])
    end

    CellularAutomaton(generations, rule, evolution)

end

function CellularAutomaton(rule::AbstractTDRule, initial_conditions, generations)

    evolution = zeros(typeof(initial_conditions[2]), size(initial_conditions, 1), size(initial_conditions, 2), generations)
    evolution[:, :, 1] = initial_conditions

    for i=2:generations
        evolution[:, :, i] = rule(evolution[:, :, i-1])
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

end # module
