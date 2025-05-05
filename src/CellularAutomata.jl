module CellularAutomata

include("generics.jl")
include("cellular_automaton.jl")
include("dca.jl")
include("cca.jl")
include("tca.jl")
include("life.jl")
include("measures.jl")

export CellularAutomaton
export DCA
export CCA
export TCA
export Life
export lempel_ziv

end # module
