using CellularAutomata

const gens = 3

blinker = [[0, 0, 0, 0, 0] [0, 0, 1, 0, 0] [0, 0, 1, 0, 0] [0, 0, 1, 0, 0] [0, 0, 0, 0, 0]]

ca = CellularAutomaton(Life((3, (2, 3))), blinker, gens)

@test ca.evolution == cat(
    [0 0 0 0 0; 0 0 0 0 0; 0 1 1 1 0; 0 0 0 0 0; 0 0 0 0 0],
    [0 0 0 0 0; 0 0 1 0 0; 0 0 1 0 0; 0 0 1 0 0; 0 0 0 0 0],
    [0 0 0 0 0; 0 0 0 0 0; 0 1 1 1 0; 0 0 0 0 0; 0 0 0 0 0];
    dims=3,
)
