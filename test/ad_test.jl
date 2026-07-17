using CellularAutomata
using ForwardDiff
using Test

const generations = 5
const ncells = 11
const x0 = collect(range(0.1, 0.9; length=ncells))

function final_state_loss(x)
    ca = CellularAutomaton(CCA(0.45), x, generations)
    return sum(abs2, ca.evolution[end, :])
end

grad = ForwardDiff.gradient(final_state_loss, x0)
@test length(grad) == ncells
@test any(!iszero, grad)

# eltype is preserved through the evolution (no hardcoded Float64)
ca32 = CellularAutomaton(CCA(0.45f0), rand(Float32, ncells), generations)
@test eltype(ca32.evolution) == Float32
