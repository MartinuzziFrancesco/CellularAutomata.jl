using CellularAutomata
using Test

@testset "constructor edge cases" begin
    @test CellularAutomaton(DCA(0), [1], 1).evolution == reshape([1], 1, 1)
    @test_throws ArgumentError CellularAutomaton(DCA(0), Int[], 1)
    @test_throws ArgumentError CellularAutomaton(DCA(0), [1], 0)
    @test_throws ArgumentError DCA(-1)
    @test_throws ArgumentError DCA(256)
    @test length(TCA(0; states=2, radius=2).codeset) == 6
    @test length(TCA(0; states=3, radius=(1, 2)).codeset) == 9
end

@testset "concrete fields" begin
    objects = (
        CellularAutomaton(DCA(30), [0, 1, 0], 2),
        DCA(30),
        TCA(3),
        CCA(0.1),
        Life(((3,), (2, 3))),
        ConstantBoundary(0.0),
    )
    for object in objects
        @test all(isconcretetype, fieldtypes(typeof(object)))
    end
end

@testset "rule hierarchy and spatial traits" begin
    @test DCA(30) isa AbstractDiscreteCellularAutomatonRule
    @test TCA(3) isa AbstractTotalisticCellularAutomatonRule
    @test CCA(0.1) isa AbstractContinuousCellularAutomatonRule
    @test Life(((3,), (2, 3))) isa AbstractLifeLikeCellularAutomatonRule
    @test spatial_dimensions(DCA(30)) == 1
    @test spatial_dimensions(TCA(3)) == 1
    @test spatial_dimensions(CCA(0.1)) == 1
    @test spatial_dimensions(Life(((3,), (2, 3)))) == 2
end

@testset "asymmetric continuous neighborhoods" begin
    rule = CCA(0.0; radius=(0, 1))
    @test rule([0.0, 0.0, 1.0]) ≈ [0.0, 0.5, 0.5]
    @test eltype(CCA(0.0f0)(Float32[0, 1])) == Float32
end

@testset "Life is synchronous and supports larger radii" begin
    input = Bool[1 1 0; 0 1 0; 0 0 0]
    copy_before = copy(input)
    Life(((3,), (2, 3)))(input)
    @test input == copy_before

    all_alive = trues(3, 4)
    result = Life(((), ()); radius=2)(all_alive)
    @test size(result) == size(all_alive)
    @test !any(result)
end
