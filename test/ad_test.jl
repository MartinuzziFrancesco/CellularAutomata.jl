using CellularAutomata
using ForwardDiff
using Test

@testset "next_state and rollout" begin
    initial = [0.1, 0.2, 0.3]
    rule = CCA(0.0)

    @test next_state(rule, initial) ≈ [0.2, 0.2, 0.2]
    @test next_state(rule, initial; boundary=ConstantBoundary()) ≈ [0.1, 0.2, 1 / 6]
    @test next_state(rule, initial; boundary=Reflecting()) ≈ [1 / 6, 0.2, 7 / 30]
    @test initial == [0.1, 0.2, 0.3]
    @test next_state(CCA(big"0.01"), BigFloat[0.1, 0.2]) isa Vector{BigFloat}

    parent = [0.0, 0.1, 0.2, 0.3, 0.0]
    initial_view = @view parent[2:4]
    @test next_state(rule, initial_view) ≈ [0.2, 0.2, 0.2]

    history = rollout(rule, initial, 2; save=true)
    @test size(history) == (3, 3)
    @test history[:, 1] == initial
    @test rollout(rule, initial, 0) === initial
    @test_throws ArgumentError rollout(rule, initial, -1)
end

@testset "multi-step differentiation" begin
    initial = fill(0.1, 4)
    objective(rule_value) = sum(rollout(CCA(rule_value; radius=0), initial, 3))
    @test ForwardDiff.derivative(objective, 0.01) ≈ 12.0
    @test ForwardDiff.jacobian(x -> rollout(CCA(0.01; radius=0), x, 3), initial) ≈
        [i == j ? 1.0 : 0.0 for i in 1:4, j in 1:4]

    function final_state_loss(x)
        ca = CellularAutomaton(CCA(0.45), x, 5)
        return sum(abs2, ca.evolution[end, :])
    end
    x0 = collect(range(0.1, 0.9; length=11))
    grad = ForwardDiff.gradient(final_state_loss, x0)
    @test length(grad) == length(x0)
    @test any(!iszero, grad)
end

@testset "eltype preservation" begin
    ca32 = CellularAutomaton(CCA(0.45f0), rand(Float32, 8), 4)
    @test eltype(ca32.evolution) == Float32
end
