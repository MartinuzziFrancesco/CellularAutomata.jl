using CellularAutomata
using Random
using Test

@testset "Stochastic rate validation" begin
    @test_throws ArgumentError Stochastic(-0.1)
    @test_throws ArgumentError Stochastic(1.1)
    @test_throws ArgumentError next_state(DCA(30), [0, 0, 1]; scheme = Stochastic(0.5))
    @test_throws ArgumentError rollout(DCA(30), [0, 0, 1], 0; scheme = Stochastic(0.5))
end

@testset "Stochastic edge rates match Synchronous" begin
    rule = DCA(30)
    state = [0, 0, 1, 0, 0]
    @test next_state(rule, state; scheme = Stochastic(0.0), rng = Xoshiro(1)) == state
    @test next_state(rule, state; scheme = Stochastic(1.0), rng = Xoshiro(1)) ==
        next_state(rule, state)
end

@testset "custom rule transitions still apply schemes" begin
    struct TestRule <: AbstractCellularAutomatonRule end
    CellularAutomata.__step(::TestRule, state, boundary) = one.(state)

    state = zeros(Int, 4)
    @test next_state(TestRule(), state) == ones(Int, 4)
    @test next_state(
        TestRule(), state; scheme = Stochastic(0.0), rng = Xoshiro(1)
    ) == state
end

@testset "Stochastic is reproducible given the same rng" begin
    rule = DCA(30)
    state = [0, 0, 1, 0, 0]
    result = next_state(rule, state; scheme = Stochastic(0.5), rng = Xoshiro(1))
    @test result == next_state(rule, state; scheme = Stochastic(0.5), rng = Xoshiro(1))
end

@testset "rollout threads a single rng across steps" begin
    rule = DCA(30)
    state = [0, 0, 1, 0, 0]

    rng = Xoshiro(1)
    first_step = next_state(rule, state; scheme = Stochastic(0.5), rng = rng)
    second_step = next_state(rule, first_step; scheme = Stochastic(0.5), rng = rng)

    @test rollout(rule, state, 2; scheme = Stochastic(0.5), rng = Xoshiro(1)) == second_step
end
