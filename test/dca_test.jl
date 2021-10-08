using CellularAutomata, Random
Random.seed!(42)

const states = 4
const radius = 1
const generations = 10
const ncells = 11
const starting_array = rand(Int, ncells)
const rule = 107396

#testing states > 2
ca = DCA(rule, starting_array; 
         generations = generations, 
         states=states, 
         radius=radius)

@test isequal(states, ca.states)
@test isequal(radius, ca.radius)
@test isequal(rule, ca.rule)
@test size(ca.cells) == (generations, ncells)

#testing states == 2
const bstates = 2
const brule = 110
const bstarting_array = rand(Bool, ncells)

bca = DCA(brule, bstarting_array; 
         generations = generations, 
         states=bstates, 
         radius=radius)

@test isequal(bstates, bca.states)
@test isequal(radius, bca.radius)
@test isequal(brule, bca.rule)
@test size(bca.cells) == (generations, ncells)
