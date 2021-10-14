using CellularAutomata

const size_space = 6
const gens = 5

glider = [[0, 0, 1, 0, 0] [0, 0, 0, 1, 0] [0, 1, 1, 1, 0]]
space = zeros(Bool, size_space, size_space)
space[1:size(glider, 1), 1:size(glider, 2)] = glider

ca = CellularAutomaton(Life((3, (2,3))), space, gens)

@test ca.evolution == cat([0 0 0 0 0 0; 0 0 1 0 0 0; 1 0 1 0 0 0; 0 1 1 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0],
[0 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 1 0 0; 0 1 1 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0],
[0 0 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 1 1 1 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0],
[0 0 0 0 0 0; 0 0 0 0 0 0; 0 1 0 1 0 0; 0 0 1 1 0 0; 0 0 1 0 0 0; 0 0 0 0 0 0],
[0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 1 0 0; 0 1 0 1 0 0; 0 0 1 1 0 0; 0 0 0 0 0 0], dims=3)

