using Test
using SafeTestsets

const GROUP = get(ENV, "GROUP", "All")
const VALID_GROUPS = ("All", "Core", "QA")

GROUP in VALID_GROUPS ||
    throw(ArgumentError("GROUP must be one of $(join(VALID_GROUPS, ", ")); got $(repr(GROUP))"))

if GROUP in ("All", "QA")
    @testset "Quality Assurance" begin
        @safetestset "Quality Assurance" include("qa.jl")
    end
end

if GROUP in ("All", "Core")
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

    @testset "AD" begin
        @safetestset "ForwardDiff through CCA" include("ad_test.jl")
    end

    @testset "Regression" begin
        @safetestset "Edge cases and hierarchy" include("regression_test.jl")
    end

    @testset "Update schemes" begin
        @safetestset "Synchronous and Stochastic" include("update_scheme_test.jl")
    end

    @testset "Life-like" begin
        @safetestset "Life glider" include("glider_test.jl")
        @safetestset "Life blinker" include("blinker_test.jl")
        @safetestset "Neighborhoods" include("neighborhood_test.jl")
    end

    @testset "Random" begin
        @safetestset "CellularAutomatonRNG" include("random_test.jl")
    end
end
