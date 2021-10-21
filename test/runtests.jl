using Test
using SafeTestsets

@testset "DCA" begin
    @safetestset "Size tests" begin include("dca_test.jl") end
    @safetestset "ECA ruleset tests" begin include("eca_ruleset_test.jl") end
end

@testset "TCA" begin
    @safetestset "Size tests" begin include("tca_test.jl") end
end

@testset "CCA" begin
    @safetestset "Size tests" begin include("cca_test.jl") end
end

@testset "Life-like" begin
    @safetestset "Life glider" begin include("glider_test.jl") end
    @safetestset "Life blinker" begin include("blinker_test.jl") end
end
