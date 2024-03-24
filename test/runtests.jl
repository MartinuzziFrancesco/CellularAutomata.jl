using Test
using SafeTestsets

@testset "Quality Assurance" begin
    @safetestset include("qa.jl")
end

@testset "DCA" begin
    @safetestset "Size tests" include("dca_test.jl")
    @safetestset "ECA ruleset tests" include("eca_ruleset_test.jl")
end

@testset "TCA" begin
    @safetestset "Size tests" include("tca_test.jl")
end

@testset "CCA" begin
    @safetestset "Size tests" include("cca_test.jl")
end

@testset "Life-like" begin
    @safetestset "Life glider" include("glider_test.jl")
    @safetestset "Life blinker" include("blinker_test.jl")
end
