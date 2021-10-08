using CellularAutomata, Random
Random.seed!(42)

const radius = 1
const generations = 10
const ncells = 11
const starting_val = rand(ncells)

const rule = 0.05

ca = CCA(rule, starting_val; generations=generations,
         radius=radius)

@test isequal(radius, ca.radius)
@test isequal(rule, ca.rule)
@test size(ca.cells) == (generations, ncells) 