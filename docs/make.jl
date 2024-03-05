 using Documenter, CellularAutomata

makedocs(;sitename="CellularAutomata.jl",
    modules=[CellularAutomata],
    clean=true,
    doctest=true,
    linkcheck=true,
    warnonly=[:missing_docs],
    pages = pages)

deploydocs(;
    repo="github.com/MartinuzziFrancesco/CellularAutomata.jl.git", push_preview=true
)