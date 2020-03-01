 mutable struct cCA
    rule::Float64
    radius::Integer
    cells::Matrix{Float64}
    
    function cCA(rule::Float64, 
            starting_val::Array{Float64}, 
            generations::Integer = 100,
            radius::Integer=1)
        
        ncells = length(starting_val)
        cells = zeros(Float64, generations, ncells)
        cells[1,:] = starting_val
        
        cells = next_gen!(cells, generations, rule)
        
        new(rule, radius, cells)
    end
end


function next_gen!(cells::Matrix{Float64}, 
        generations::Integer,
        rule::Float64)
     
    l = size(cells)[2]
    nextgen = zeros(Float64, l)
    
    for j = 1:generations-1
        for i = 1:l
            left   = cells[j, mod1(i - 1, l)]
            middle = cells[j, mod1(i, l)]
            right  = cells[j, mod1(i + 1, l)]
            nextgen[i] = modf((left+middle+right)/3+rule)[1]
        end
        
    cells[j+1,:] = nextgen
    end
    return cells
end
