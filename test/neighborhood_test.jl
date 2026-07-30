using CellularAutomata
using Test

struct HorizontalNeighborhood <: AbstractNeighborhood
    radius::Int
end

CellularAutomata.neighborhood_radius(neighborhood::HorizontalNeighborhood) =
    neighborhood.radius
CellularAutomata.neighborhood_offsets(::HorizontalNeighborhood) = ((0, -1), (0, 1))

@testset "constructor validation" begin
    @test neighborhood_radius(Moore(2)) == 2
    @test neighborhood_radius(VonNeumann(; radius = 2)) == 2
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
    moore_offsets = Set(neighborhood_offsets(Moore(1)))
    @test length(moore_offsets) == 8
    @test (0, 0) ∉ moore_offsets
    @test (1, 1) ∈ moore_offsets

    vonneumann_offsets = Set(neighborhood_offsets(VonNeumann(1)))
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

@testset "custom neighborhoods implement the public interface" begin
    neighborhood = HorizontalNeighborhood(1)
    life = Life(((2,), ()); neighborhood)
    horizontal_pair = Bool[0 0 0; 1 0 1; 0 0 0]

    @test neighborhood_radius(life) == 1
    @test next_state(life, horizontal_pair)[2, 2]
end

@testset "neighborhood_radius reflects the configured neighborhood" begin
    @test neighborhood_radius(Life(((3,), (2, 3)); neighborhood = VonNeumann(3))) == 3
end
