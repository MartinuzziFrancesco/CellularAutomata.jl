 mutable struct CCA{T,M}
    rule::T
    radius::Int
    cells::M
end

function CCA(rule, starting_val; 
             generations=100,
             radius=1)

    ncells = length(starting_val)
    cells = zeros(Float64, generations, ncells)
    cells[1,:] = starting_val
    cells = cont_next_gen!(cells, generations, rule)
    CCA(rule, radius, cells)

end

function cont_next_gen!(cells, generations, rule)
     
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
