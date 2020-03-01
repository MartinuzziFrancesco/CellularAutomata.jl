using Test
using SafeTestsets

@time @safetestset "dca" begin include("dca_test.jl") end
@time @safetestset "cca" begin include("cca_test.jl") end

