using CellularAutomata, Random
Random.seed!(42)

const states = 4
const radius = 1
const generations = 10
const ncells = 11
const starting_array = rand(Int, ncells)
const rule = 107396

#testing states > 2
ca = CellularAutomaton(DCA(rule, states=states), starting_array, generations)

@test size(ca.evolution) == (generations, ncells)

#testing states == 2
const bstates = 2
const brule = 110
const bstarting_array = rand(Bool, ncells)

bca = ca = CellularAutomaton(DCA(brule), bstarting_array, generations)

@test size(bca.evolution) == (generations, ncells)
