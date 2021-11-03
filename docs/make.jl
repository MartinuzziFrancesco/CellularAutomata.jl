 using Documenter, CellularAutomata

makedocs(sitename="CellularAutomata.jl", 
pages = [
    "CellularAutomata.jl" => "index.md",
    "Examples" => [
        "One dimensional CA" => "onedim/onedimensionca.md"
        "Two dimensional CA" => "twodim/twodimensionca.md"
        ],
    "User Guide" => Any[
        "One Dimensional CA" => "user/onedimensionca.md"
        "Two Dimensial CA" => "user/twodimensionca.md"

        ]
    ])
