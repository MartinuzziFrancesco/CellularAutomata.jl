 using Documenter, CellularAutomata

makedocs(sitename="CellularAutomata.jl", 
pages = [
    "index.md"
    "Examples" => [
        
        "One dimensional CA" => "onedimensionca.md"
        "Two dimensional CA" => "twodimensionca.md"
        ]])
