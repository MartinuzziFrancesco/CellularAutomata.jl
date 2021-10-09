module CellularAutomata

abstract type AbstractRule end
abstract type AbstractODRule <: AbstractRule end
abstract type AbstractCA end

struct CellularAutomaton{F,E} <: AbstractCA
    generations::Int
    generation_fun::F
    evolution::E
end

function CellularAutomaton(rule::AbstractODRule, initial_conditions, generations)

    evolution = zeros(typeof(initial_conditions[2]), generations, length(initial_conditions))
    evolution[1,:] = initial_conditions

    for i=2:generations
        evolution[i,:] = rule(evolution[i-1,:])
    end

    CellularAutomaton(generations, rule, evolution)

end

export CellularAutomaton

include("dca.jl")
export DCA

include("cca.jl")
export CCA

end # module
