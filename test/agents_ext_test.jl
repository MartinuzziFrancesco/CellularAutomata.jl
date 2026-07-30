using CellularAutomata
using Agents
using Test

@agent struct Forager(GridAgent{2}) end
@agent struct Point1D(GridAgent{1}) end

@testset "cellular automaton advances like rollout" begin
    glider = [0 0 1 0 0; 0 0 0 1 0; 0 1 1 1 0; 0 0 0 0 0; 0 0 0 0 0]
    life = Life((3, (2, 3)))

    model = cellular_automaton_abm(
        Forager, life, glider;
        agent_step! = (agent, model) -> walk!(agent, (rand((-1, 0, 1)), rand((-1, 0, 1))), model)
    )
    add_agent!(model)
    add_agent!(model)

    step!(model, 3)

    @test cellular_automaton_state(model) == rollout(life, glider, 3)
    @test nagents(model) == 2
end

@testset "no agent_step! given, model_step! still advances the automaton" begin
    dca = DCA(30)
    state = [0, 0, 1, 0, 0]

    model = cellular_automaton_abm(Point1D, dca, state)
    step!(model, 2)

    @test cellular_automaton_state(model) == rollout(dca, state, 2)
end

@testset "extra model_step! runs after the automaton update" begin
    dca = DCA(30)
    state = [0, 0, 1, 0, 0]
    calls = Ref(0)

    model = cellular_automaton_abm(
        Point1D, dca, state; model_step! = model -> (calls[] += 1)
    )
    step!(model, 3)

    @test calls[] == 3
    @test cellular_automaton_state(model) == rollout(dca, state, 3)
end

@testset "rejects a conflicting properties key" begin
    dca = DCA(30)
    state = [0, 0, 1, 0]
    @test_throws ArgumentError cellular_automaton_abm(
        Point1D, dca, state; properties = (; cellular_automaton = nothing)
    )
end
