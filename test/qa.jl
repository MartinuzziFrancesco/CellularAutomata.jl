using CellularAutomata
using Aqua: Aqua

Aqua.test_all(CellularAutomata; ambiguities = false, deps_compat = (check_extras = false))

# JET 0.9 (the only release available on Julia < 1.12) reports false positives
# inside Base's `digits!` BigInt path when analyzing `__digits_ruleset` abstractly.
@static if VERSION >= v"1.12"
    using JET
    JET.test_package(CellularAutomata)
end
