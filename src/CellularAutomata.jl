module CellularAutomata

include("generics.jl")
include("cellular_automaton.jl")
include("rules/dca.jl")
include("rules/cca.jl")
include("rules/tca.jl")
include("rules/life.jl")
include("measures.jl")

export CellularAutomaton
export DCA
export CCA
export TCA
export Life
export lempel_ziv

end # module
