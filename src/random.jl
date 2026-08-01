"""
    CellularAutomatonRNG(rule=DCA(30); size=127, seed=rand(RandomDevice(), UInt),
        skip=nothing, start=nothing, warmup=4) -> CellularAutomatonRNG

Pseudorandom number generator driven by a one-dimensional cellular automaton, in the
style of Wolfram's original Rule 30 generator (Mathematica's `"ExtendedCA"` method).
Only binary rules are supported: mapping a correlated multi-state CA stream to unbiased
bits requires assumptions that the generic rule interface cannot guarantee.
The seed is mixed across a tape of `size` cells. The automaton is then advanced for
`warmup * size` throwaway generations before output begins. Each subsequent generation
advances the automaton and reads one or more cells as output bits.

By default only the center cell is read, one bit per generation. Passing `skip` reads
every `skip`-th cell starting from `start` across the whole tape instead, producing many
bits per generation for much higher throughput, the same trick `"ExtendedCA"` uses
(there with `Skip=4`) to avoid the correlation between adjacent cells that a
finite-radius rule would otherwise introduce within a single generation.

# Arguments

  - `rule`: Binary one-dimensional discrete cellular-automaton rule driving the tape.
    Custom rules must implement `cell_state_count(rule)`. Defaults to `DCA(30)`.

# Keywords

  - `size`: Number of cells on the tape. Even values are bumped up by 1 to keep a
    well-defined center cell. Defaults to 127.
  - `seed`: Integer mixed across the initial tape. Defaults to a seed drawn from the OS
    entropy source (`RandomDevice()`).
  - `skip`: When `nothing` (the default), read only the cell at `start`. Otherwise, read
    every `skip`-th cell starting from `start` across the tape each generation.
  - `start`: Index of the first cell read each generation. Defaults to the center cell
    when `skip` is `nothing`, or to `1` when `skip` is given.
  - `warmup`: Number of throwaway generations per tape cell after initialization.
    Defaults to 4.

# Throws

  - `ArgumentError`: If `rule` does not implement `cell_state_count`, if the rule is not
    binary, if `size` is smaller than 3, if `skip` is smaller than 1, if `start` is
    outside `1:size`, or if `warmup` is smaller than 1.

# Examples

```jldoctest
julia> using CellularAutomata

julia> rng = CellularAutomatonRNG(DCA(30); size = 7, seed = 1);

julia> rand(rng, UInt8)
0xb7

julia> wide_rng = CellularAutomatonRNG(DCA(30); size = 15, seed = 2, skip = 4);

julia> rand(wide_rng, UInt8)
0xd4
```
"""
mutable struct CellularAutomatonRNG{R <: AbstractDiscreteCellularAutomatonRule} <:
    AbstractRNG
    rule::R
    state::Vector{Int}
    positions::Vector{Int}
    pending::Vector{Int}
    warmup::Int
end

function CellularAutomatonRNG(
        rule::AbstractDiscreteCellularAutomatonRule = DCA(30);
        size::Integer = 127,
        seed::Integer = rand(Random.RandomDevice(), UInt),
        skip::Union{Nothing, Integer} = nothing,
        start::Union{Nothing, Integer} = nothing,
        warmup::Integer = 4
    )
    size >= 3 || throw(ArgumentError("size must be at least 3"))
    warmup >= 1 || throw(ArgumentError("warmup must be at least 1"))
    size <= typemax(Int) || throw(ArgumentError("size must fit in Int"))
    warmup <= typemax(Int) || throw(ArgumentError("warmup must fit in Int"))
    size = iseven(size) ? Int(size) + 1 : Int(size)
    warmup = Int(warmup)
    warmup <= typemax(Int) ÷ size ||
        throw(ArgumentError("warmup * size must fit in Int"))
    __validate_rng_rule(rule)
    actual_start = if start === nothing
        skip === nothing ? (size + 1) ÷ 2 : 1
    else
        (1 <= start <= size) || throw(ArgumentError("start must be between 1 and size"))
        Int(start)
    end
    positions = if skip === nothing
        [actual_start]
    else
        skip >= 1 || throw(ArgumentError("skip must be at least 1"))
        collect(actual_start:Int(skip):Int(size))
    end
    rng = CellularAutomatonRNG(rule, zeros(Int, size), positions, Int[], warmup)
    Random.seed!(rng, seed)
    return rng
end

function __validate_rng_rule(rule::AbstractDiscreteCellularAutomatonRule)
    applicable(cell_state_count, rule) || throw(
        ArgumentError(
            "$(typeof(rule)) must implement CellularAutomata.cell_state_count(rule) " *
                "to be used with CellularAutomatonRNG"
        )
    )
    states = cell_state_count(rule)
    states == 2 || throw(
        ArgumentError(
            "CellularAutomatonRNG requires a binary rule with 2 cell states; " *
                "$(typeof(rule)) reports $states"
        )
    )
    return nothing
end

function __splitmix64(state::UInt64)
    state += 0x9e3779b97f4a7c15
    mixed = state
    mixed = (mixed ⊻ (mixed >> 30)) * 0xbf58476d1ce4e5b9
    mixed = (mixed ⊻ (mixed >> 27)) * 0x94d049bb133111eb
    return mixed ⊻ (mixed >> 31), state
end

function Random.seed!(rng::CellularAutomatonRNG, seed::Integer)
    seed_state = seed % UInt64
    mixed = zero(UInt64)
    bits_remaining = 0
    for index in eachindex(rng.state)
        if iszero(bits_remaining)
            mixed, seed_state = __splitmix64(seed_state)
            bits_remaining = 64
        end
        rng.state[index] = Int(mixed & 1)
        mixed >>= 1
        bits_remaining -= 1
    end
    empty!(rng.pending)
    for _ in 1:(rng.warmup * length(rng.state))
        rng.state = next_state(rng.rule, rng.state)
    end
    return rng
end

function __next_bit!(rng::CellularAutomatonRNG)
    if isempty(rng.pending)
        rng.state = next_state(rng.rule, rng.state)
        for position in Iterators.reverse(rng.positions)
            push!(rng.pending, rng.state[position])
        end
    end
    return pop!(rng.pending)
end

function Random.rand(
        rng::CellularAutomatonRNG, ::Random.SamplerType{T}
    ) where {T <: Base.BitInteger}
    U = unsigned(T)
    value = zero(U)
    for _ in 1:(8 * sizeof(T))
        value = (value << 1) | U(__next_bit!(rng))
    end
    return value % T
end

Random.rand(rng::CellularAutomatonRNG, ::Random.SamplerType{Bool}) = Bool(__next_bit!(rng))

Random.Sampler(
    ::Type{<:CellularAutomatonRNG}, ::Type{Float16}, ::Random.Repetition
) = Random.SamplerType{Float16}()
Random.Sampler(
    ::Type{<:CellularAutomatonRNG}, ::Type{Float32}, ::Random.Repetition
) = Random.SamplerType{Float32}()
Random.Sampler(
    ::Type{<:CellularAutomatonRNG}, ::Type{Float64}, ::Random.Repetition
) = Random.SamplerType{Float64}()

function __rand_significand!(rng::CellularAutomatonRNG, bit_count::Int)
    significand = zero(UInt64)
    for _ in 1:bit_count
        significand = (significand << 1) | UInt64(__next_bit!(rng))
    end
    return significand
end

Random.rand(rng::CellularAutomatonRNG, ::Random.SamplerType{Float16}) =
    ldexp(Float16(__rand_significand!(rng, precision(Float16))), -precision(Float16))
Random.rand(rng::CellularAutomatonRNG, ::Random.SamplerType{Float32}) =
    ldexp(Float32(__rand_significand!(rng, precision(Float32))), -precision(Float32))
Random.rand(rng::CellularAutomatonRNG, ::Random.SamplerType{Float64}) =
    ldexp(Float64(__rand_significand!(rng, precision(Float64))), -precision(Float64))

function Base.show(io::IO, rng::CellularAutomatonRNG)
    return print(
        io, "CellularAutomatonRNG(", rng.rule, "; size=", length(rng.state),
        ", positions=", rng.positions, ")"
    )
end
