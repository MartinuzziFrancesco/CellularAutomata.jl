using Documenter, CellularAutomata
include("pages.jl")

makedocs(;
    sitename="CellularAutomata.jl",
    modules=[CellularAutomata],
    clean=true,
    doctest=true,
    linkcheck=true,
    format=Documenter.HTML(;
        assets=["assets/favicon.ico"],
        canonical="https://MartinuzziFrancesco.github.io/CellularAutomata.jl",
    ),
    warnonly=[:missing_docs],
    pages=pages,
)

deploydocs(;
    repo="github.com/MartinuzziFrancesco/CellularAutomata.jl.git", push_preview=true
)
