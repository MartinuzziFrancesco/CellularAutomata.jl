using CellularAutomata

states = 4
radius = 1
generations = 10
ncells = 11
starting_val = convert(Array{Int}, rand([0, 1], ncells))
rule = 107396

#testing states > 2
ca = DCA(rule, starting_val, generations, states, radius)

@test isequal(states, ca.states)
@test isequal(radius, ca.radius)
@test isequal(rule, ca.rule)
@test size(ca.cells) == (generations, ncells)

#testing states == 2
states = 2
rule = 110

bca = DCA(rule, starting_val, generations, states, radius)

@test isequal(states, bca.states)
@test isequal(radius, bca.radius)
@test isequal(rule, bca.rule)
@test size(bca.cells) == (generations, ncells)
