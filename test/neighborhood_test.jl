using CellularAutomata
using Test

@testset "constructor validation" begin
    @test Moore(2).radius == 2
    @test VonNeumann(; radius = 2).radius == 2
    @test_throws ArgumentError Moore(-1)
    @test_throws ArgumentError VonNeumann(-1)
    @test_throws ArgumentError Life(((3,), (2, 3)); radius = 0)
    @test_throws ArgumentError Life(((3,), (2, 3)); neighborhood = VonNeumann(0))
end

@testset "show methods" begin
    @test repr(Moore(1)) == "Moore(1)"
    @test repr(VonNeumann(2)) == "VonNeumann(2)"
    @test repr(Life(((3,), (2, 3)))) == "Life(((3,), (2, 3)); radius=1)"
    @test repr(Life(((3,), (2, 3)); neighborhood = VonNeumann(1))) ==
        "Life(((3,), (2, 3)); neighborhood=VonNeumann(1))"
end

@testset "offsets exclude the center and match each neighborhood's shape" begin
    moore_offsets = Set(CellularAutomata.__offsets(Moore(1)))
    @test length(moore_offsets) == 8
    @test (0, 0) ∉ moore_offsets
    @test (1, 1) ∈ moore_offsets

    vonneumann_offsets = Set(CellularAutomata.__offsets(VonNeumann(1)))
    @test length(vonneumann_offsets) == 4
    @test (0, 0) ∉ vonneumann_offsets
    @test (1, 1) ∉ vonneumann_offsets
    @test (1, 0) ∈ vonneumann_offsets
end

@testset "VonNeumann and Moore neighborhoods can disagree" begin
    diagonal_corners = zeros(Bool, 5, 5)
    diagonal_corners[[2, 4], [2, 4]] .= true

    moore_result = next_state(Life(((4,), ()); radius = 1), diagonal_corners)
    vonneumann_result = next_state(
        Life(((4,), ()); neighborhood = VonNeumann(1)), diagonal_corners
    )
    @test moore_result[3, 3] == true
    @test vonneumann_result[3, 3] == false
end

@testset "neighborhood_radius reflects the configured neighborhood" begin
    @test neighborhood_radius(Life(((3,), (2, 3)); neighborhood = VonNeumann(3))) == 3
end
