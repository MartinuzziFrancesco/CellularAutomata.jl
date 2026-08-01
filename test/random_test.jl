using CellularAutomata
using Random
using Test

module RandomTestRules
    using CellularAutomata

    struct MissingStateCountRule <: AbstractDiscreteCellularAutomatonRule end
    CellularAutomata.__step(::MissingStateCountRule, state, boundary) = copy(state)

    struct BinaryRule <: AbstractDiscreteCellularAutomatonRule end
    CellularAutomata.cell_state_count(::BinaryRule) = 2
    CellularAutomata.__step(::BinaryRule, state, boundary) = copy(state)
end

@testset "size validation and even auto-correction" begin
    @test_throws ArgumentError CellularAutomatonRNG(; size = 1)
    @test_throws ArgumentError CellularAutomatonRNG(; size = 2)

    rng = CellularAutomatonRNG(; size = 8)
    @test occursin("size=9", sprint(show, rng))
end

@testset "seeding is reproducible" begin
    a = CellularAutomatonRNG(; seed = 7)
    b = CellularAutomatonRNG(; seed = 7)
    @test rand(a, UInt64, 8) == rand(b, UInt64, 8)
end

@testset "different seeds diverge" begin
    a = CellularAutomatonRNG(; seed = 1)
    b = CellularAutomatonRNG(; seed = 2)
    @test rand(a, UInt64, 8) != rand(b, UInt64, 8)

    c = CellularAutomatonRNG(; seed = 0)
    d = CellularAutomatonRNG(; seed = 508)
    @test rand(c, UInt64, 8) != rand(d, UInt64, 8)
end

@testset "reseeding restores the stream and clears buffered bits" begin
    rng = CellularAutomatonRNG(; seed = 7, skip = 4)
    expected = rand(rng, UInt64, 8)
    rand(rng, Bool)
    Random.seed!(rng, 7)
    @test rand(rng, UInt64, 8) == expected
end

@testset "supports the AbstractRNG scalar interface" begin
    rng = CellularAutomatonRNG(; seed = 1)
    @test rand(rng, UInt8) isa UInt8
    @test rand(rng, UInt64) isa UInt64
    @test rand(rng, Bool) isa Bool
    @test rand(rng, Float16) isa Float16
    @test rand(rng, Float32) isa Float32
    @test 0.0 <= rand(rng, Float64) < 1.0
    @test rand(rng, 1:100) in 1:100
end

@testset "integer draws consume one contiguous bitstream" begin
    bytes_rng = CellularAutomatonRNG(; seed = 1)
    word_rng = CellularAutomatonRNG(; seed = 1)
    high = rand(bytes_rng, UInt8)
    low = rand(bytes_rng, UInt8)
    @test rand(word_rng, UInt16) == (UInt16(high) << 8) | UInt16(low)

    bool_rng = CellularAutomatonRNG(; seed = 1)
    byte_rng = CellularAutomatonRNG(; seed = 1)
    bits = foldl(
        (value, bit) -> (value << 1) | UInt8(bit),
        (rand(bool_rng, Bool) for _ in 1:8); init = UInt8(0)
    )
    @test rand(byte_rng, UInt8) == bits
end

@testset "supports array and Bool sampling" begin
    rng = CellularAutomatonRNG(; seed = 1)
    @test rand(rng, 5, 5) isa Matrix{Float64}
    @test rand(rng, Bool, 5, 5) isa Matrix{Bool}
    @test rand(rng, UInt8, 5, 5) isa Matrix{UInt8}
end

@testset "Bool sampling matches the raw automaton bit" begin
    rng = CellularAutomatonRNG(DCA(30); size = 7, seed = 0)
    state = copy(rng.state)
    state = next_state(DCA(30), state)
    @test rand(rng, Bool) == Bool(state[4] & 1)
end

@testset "show prints the actual read positions, not their count" begin
    rng = CellularAutomatonRNG(; seed = 1)
    @test occursin("positions=[64]", sprint(show, rng))
end

@testset "matches a hand rolled Rule 30 center column" begin
    rng = CellularAutomatonRNG(DCA(30); size = 7, seed = 0)
    state = copy(rng.state)
    bits = UInt64(0)
    for _ in 1:64
        state = next_state(DCA(30), state)
        bits = (bits << 1) | UInt64(state[4] & 1)
    end
    @test rand(rng, UInt64) == bits
end

@testset "skip validation" begin
    @test_throws ArgumentError CellularAutomatonRNG(; skip = 0)
end

@testset "skip does not change center-only default behavior" begin
    a = CellularAutomatonRNG(DCA(30); size = 7, seed = 1)
    b = CellularAutomatonRNG(DCA(30); size = 7, seed = 1)
    @test rand(a, UInt64, 8) == rand(b, UInt64, 8)
end

@testset "skip is reproducible and diverges across seeds" begin
    a = CellularAutomatonRNG(; seed = 7, skip = 4)
    b = CellularAutomatonRNG(; seed = 7, skip = 4)
    @test rand(a, UInt64, 8) == rand(b, UInt64, 8)

    c = CellularAutomatonRNG(; seed = 1, skip = 4)
    d = CellularAutomatonRNG(; seed = 2, skip = 4)
    @test rand(c, UInt64, 8) != rand(d, UInt64, 8)
end

@testset "matches a hand rolled multi-cell Rule 30 harvest with skip" begin
    # size=15, skip=4 gives positions 1:4:15 (4 cells/generation), and 4 divides
    # 64 evenly so this covers exactly 16 generations with no leftover bits.
    rng = CellularAutomatonRNG(DCA(30); size = 15, seed = 0, skip = 4)
    state = copy(rng.state)
    bits = UInt64(0)
    for _ in 1:16
        state = next_state(DCA(30), state)
        for p in 1:4:15
            bits = (bits << 1) | UInt64(state[p] & 1)
        end
    end
    @test rand(rng, UInt64) == bits
end

@testset "start validation" begin
    @test_throws ArgumentError CellularAutomatonRNG(; start = 0)
    @test_throws ArgumentError CellularAutomatonRNG(; size = 7, start = 8)
end

@testset "start overrides the single read position when skip is not given" begin
    rng = CellularAutomatonRNG(DCA(30); size = 7, seed = 0, start = 2)
    state = copy(rng.state)
    bits = UInt64(0)
    for _ in 1:64
        state = next_state(DCA(30), state)
        bits = (bits << 1) | UInt64(state[2] & 1)
    end
    @test rand(rng, UInt64) == bits
end

@testset "matches a hand rolled multi-cell harvest with start and skip" begin
    # size=15, start=2, skip=4 gives positions 2:4:15 == [2, 6, 10, 14]
    rng = CellularAutomatonRNG(DCA(30); size = 15, seed = 0, start = 2, skip = 4)
    state = copy(rng.state)
    bits = UInt64(0)
    for _ in 1:16
        state = next_state(DCA(30), state)
        for p in 2:4:15
            bits = (bits << 1) | UInt64(state[p] & 1)
        end
    end
    @test rand(rng, UInt64) == bits
end

@testset "non-binary rules are rejected at construction" begin
    @test_throws ArgumentError CellularAutomatonRNG(DCA(1; states = 3))
    @test_throws ArgumentError CellularAutomatonRNG(TCA(1; states = 3))
end

@testset "custom rules receive contextual interface validation" begin
    @test_throws ArgumentError CellularAutomatonRNG(RandomTestRules.MissingStateCountRule())

    a = CellularAutomatonRNG(RandomTestRules.BinaryRule(); seed = 5)
    b = CellularAutomatonRNG(RandomTestRules.BinaryRule(); seed = 5)
    @test rand(a, UInt64, 4) == rand(b, UInt64, 4)
end

@testset "binary rules retain their exact stream" begin
    rng = CellularAutomatonRNG(DCA(30); size = 7, seed = 1)
    @test rand(rng, UInt8) == 0xb7
end
