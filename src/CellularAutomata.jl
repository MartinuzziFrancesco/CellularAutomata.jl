module CellularAutomata

using ConcreteStructs: @concrete
using Random: Random, AbstractRNG

include("generics.jl")
include("cellular_automaton.jl")
include("rules/dca.jl")
include("rules/cca.jl")
include("rules/tca.jl")
include("rules/life.jl")
include("measures.jl")
include("random.jl")

export AbstractCellularAutomaton, AbstractCellularAutomatonRule
export AbstractBoundaryCondition, Periodic, Reflecting, ConstantBoundary
export AbstractUpdateScheme, Synchronous, Stochastic
export AbstractNeighborhood, Moore, VonNeumann
export AbstractDiscreteCellularAutomatonRule
export AbstractContinuousCellularAutomatonRule
export AbstractTotalisticCellularAutomatonRule
export AbstractLifeLikeCellularAutomatonRule
export CellularAutomaton
export next_state, rollout, spatial_dimensions
export cellular_automaton_rule, evolution_history, generation_count
export neighborhood_offsets, neighborhood_radius, rule_lookup_table, cell_state_count
export DCA
export CCA
export TCA
export Life
export lempel_ziv
export CellularAutomatonRNG

end # module
