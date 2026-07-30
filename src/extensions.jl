"""
    cellular_automaton_abm(AgentType, rule, state; kwargs...)

Build an `Agents.StandardABM` that advances `state` under `rule` once per model step,
alongside independently-scheduled agents of type `AgentType`. Requires `Agents` to be
loaded (implemented in a package extension).

# Arguments

  - `AgentType`: agent type living on the model's grid, as required by
    `Agents.StandardABM`.
  - `rule`: an [`AbstractCellularAutomatonRule`](@ref) advanced each model step.
  - `state`: the initial cellular-automaton state array.

# Keywords

  - `boundary`: boundary condition passed to [`next_state`](@ref). Defaults to
    `Periodic()`.
  - `scheme`: update scheme passed to [`next_state`](@ref). Defaults to `Synchronous()`.
  - `rng`: random number generator, required by stochastic schemes.
  - `space`: an `Agents.AbstractSpace`. Defaults to a `GridSpaceSingle` sized to `state`,
    periodic if `boundary isa Periodic`.
  - `agent_step!`: per-agent step function, as in `Agents.StandardABM`.
  - `model_step!`: additional model step function, called after the cellular automaton
    has been advanced. Defaults to a no-op.
  - `properties`: a `NamedTuple` of additional model properties, merged with the
    cellular-automaton state stored under the `cellular_automaton` key.
  - other `kwargs` are passed through to `Agents.StandardABM`.

# Throws

  - `ArgumentError`: if `properties` already has a `cellular_automaton` key.
"""
function cellular_automaton_abm end

"""
    cellular_automaton_state(model)

Return the current cellular-automaton state array stored in an ABM built by
[`cellular_automaton_abm`](@ref). Requires `Agents` to be loaded.
"""
function cellular_automaton_state end
