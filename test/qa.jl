using CellularAutomata
using Aqua: Aqua
using JET

Aqua.test_all(CellularAutomata; ambiguities=false, deps_compat=(check_extras = false))
JET.test_package(CellularAutomata)