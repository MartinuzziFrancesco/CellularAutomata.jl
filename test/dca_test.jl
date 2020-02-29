using odCellularAutomata
 
states = 4
radius = 1
generations = 100
ncells = 111
starting_val = zeros(Integer, ncells)
midpoint = Int(floor(ncells/2)+1)
starting_val[midpoint] = 1
starting_val2 = convert(Array{Integer}, rand([0, 1], ncells))

rule = 107396

ca = dCA(rule, starting_val, generations, states, radius)

@test isequal(states, ca.states)
@test isequal(radius, ca.radius)
@test isequal(rule, ca.rule)
@test size(ca.cells) == (generations, ncells)
