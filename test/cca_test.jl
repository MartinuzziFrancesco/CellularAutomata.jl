using CellularAutomata, Random
Random.seed!(42)

const radius = 1
const generations = 10
const ncells = 11
const starting_val = rand(ncells)

const rule = 0.05

ca = ca = CellularAutomaton(CCA(rule), starting_val, generations)

@test size(ca.evolution) == (generations, ncells)
