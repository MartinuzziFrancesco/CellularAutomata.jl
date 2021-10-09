using Test
using SafeTestsets

@time @safetestset "DCA.jl" begin include("dca_test.jl") end
@time @safetestset "TCA.jl" begin include("tca_test.jl") end
@time @safetestset "CCA.jl" begin include("cca_test.jl") end

