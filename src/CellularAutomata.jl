module CellularAutomata

using ConcreteStructs: @concrete

include("generics.jl")
include("cellular_automaton.jl")
include("rules/dca.jl")
include("rules/cca.jl")
include("rules/tca.jl")
include("rules/life.jl")
include("measures.jl")

export AbstractCellularAutomaton, AbstractCellularAutomatonRule
export AbstractBoundaryCondition, Periodic, Reflecting, ConstantBoundary
export AbstractDiscreteCellularAutomatonRule
export AbstractContinuousCellularAutomatonRule
export AbstractTotalisticCellularAutomatonRule
export AbstractLifeLikeCellularAutomatonRule
export CellularAutomaton
export next_state, rollout, spatial_dimensions
export DCA
export CCA
export TCA
export Life
export lempel_ziv

end # module
