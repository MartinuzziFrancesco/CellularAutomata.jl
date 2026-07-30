module CellularAutomataAgentsExt

using CellularAutomata:
    CellularAutomata, AbstractCellularAutomatonRule, AbstractBoundaryCondition,
    AbstractUpdateScheme, Periodic, Synchronous, next_state
using Agents: Agents, StandardABM, GridSpaceSingle, dummystep
using Random: default_rng

mutable struct __CAField{R, S, B, U, G}
    rule::R
    state::S
    boundary::B
    scheme::U
    rng::G
end

function __step_ca!(field::__CAField)
    field.state = next_state(
        field.rule, field.state; boundary = field.boundary, scheme = field.scheme,
        rng = field.rng
    )
    return field.state
end

function CellularAutomata.cellular_automaton_abm(
        AgentType, rule::AbstractCellularAutomatonRule, state;
        boundary::AbstractBoundaryCondition = Periodic(),
        scheme::AbstractUpdateScheme = Synchronous(),
        rng = default_rng(),
        space = GridSpaceSingle(size(state); periodic = boundary isa Periodic),
        agent_step! = dummystep,
        model_step! = Returns(nothing),
        properties::NamedTuple = NamedTuple(),
        kwargs...
    )
    haskey(properties, :cellular_automaton) &&
        throw(ArgumentError("properties already has a `cellular_automaton` key"))
    field = __CAField(rule, state, boundary, scheme, rng)
    merged_properties = merge((; cellular_automaton = field), properties)
    wrapped_model_step! = model -> (__step_ca!(field); model_step!(model); nothing)
    return StandardABM(
        AgentType, space; properties = merged_properties,
        agent_step! = agent_step!, model_step! = wrapped_model_step!, kwargs...
    )
end

CellularAutomata.cellular_automaton_state(model) = model.cellular_automaton.state

end # module
