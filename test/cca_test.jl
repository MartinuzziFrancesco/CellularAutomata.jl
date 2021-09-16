radius = 1
generations = 10
ncells = 11
starting_val = convert(Array{Float64}, rand(Float64, ncells))

rule = 0.05

ca = DCA(rule, starting_val, generations, radius)

@test isequal(radius, ca.radius)
@test isequal(rule, ca.rule)
@test size(ca.cells) == (generations, ncells) 
