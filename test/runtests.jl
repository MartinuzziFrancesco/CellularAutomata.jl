using Test
using SafeTestsets

@time @safetestset "Constructor" begin include("dca_test.jl") end
