# General APIs

```@docs
    CellularAutomaton
    next_state
    rollout
    AbstractUpdateScheme
    Synchronous
    Stochastic
    cellular_automaton_rule
    evolution_history
    generation_count
    neighborhood_radius
    rule_lookup_table
    cell_state_count
    Periodic
    Reflecting
    ConstantBoundary
    AbstractCellularAutomaton
    AbstractCellularAutomatonRule
    AbstractBoundaryCondition
    AbstractDiscreteCellularAutomatonRule
    AbstractContinuousCellularAutomatonRule
    AbstractTotalisticCellularAutomatonRule
    AbstractLifeLikeCellularAutomatonRule
    spatial_dimensions
    lempel_ziv
```

## Extensions

```@docs
    cellular_automaton_abm
    cellular_automaton_state
```

`cellular_automaton_abm`/`cellular_automaton_state` are implemented in a package
extension and require `Agents` to be loaded.
