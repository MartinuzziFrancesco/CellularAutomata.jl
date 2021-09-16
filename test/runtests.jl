using Test
using SafeTestsets
using CellularAutomata

@time @safetestset "DCA.jl" begin include("dca_test.jl") end
@time @safetestset "CCA.jl" begin include("cca_test.jl") end

