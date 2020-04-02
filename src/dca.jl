 
mutable struct dCA
    rule::Int
    ruleset::Array{Int}
    states::Int
    radius::Int
    cells::Matrix{Int}
    
    function dCA(rule::Int, 
            starting_val::Array{Int}, 
            generations::Int = 100,
            states::Int = 2, 
            radius::Int=1)
        
        ncells = length(starting_val)
        cells = zeros(Int, generations, ncells)
        cells[1,:] = starting_val
        ruleset = conversion(rule, states, radius)
        
        if states == 2
            cells = next_gen!(cells, generations, ruleset)
        else 
            cells = totalistic_next_gen!(cells, generations, ruleset)
        end
        
        new(rule, ruleset, states, radius, cells)
    end
end

function conversion(bin::Int, 
        states::Int, 
        radius::Int)
    
    if states == 2
        bin_array = zeros(Int, states^(2*radius+1))
        for i=states^(2*radius+1):-1:1
            bin_array[i] = bin % states
            bin = floor(bin/states)
        end
    else
        bin_array = zeros(Int, (2*radius+1)*states-2)
        for i=(2*radius+1)*states-2:-1:1
            bin_array[i] = bin % states
            bin = floor(bin/states)
        end
    end
    return bin_array
end

function rules(ruleset::Array{Int}, 
        left::Int, 
        middle::Int,
        right::Int)
    
    lng = length(ruleset)
    return ruleset[mod1(lng-(4*left + 2*middle + right), lng)]
end

function totalistic_rule(ruleset::Array{Int}, 
        left::Int, 
        middle::Int,
        right::Int)
    
    lng = length(ruleset)
    return ruleset[mod1(lng-(left + middle + right), lng)]
end

function next_gen!(cells::Matrix{Int}, 
        generations::Int,
        ruleset::Array{Int})
     
    l = size(cells)[2]
    nextgen = zeros(Int, l)
    
    for j = 1:generations-1
        for i = 1:l
            left   = cells[j, mod1(i - 1, l)]
            middle = cells[j, mod1(i, l)]
            right  = cells[j, mod1(i + 1, l)]
            nextgen[i] = rules(ruleset, left, middle, right)
        end
        
    cells[j+1,:] = nextgen
    end
    return cells
end

function totalistic_next_gen!(cells::Matrix{Int}, 
        generations::Int,
        ruleset::Array{Int})
    
    l = size(cells)[2]
    nextgen = zeros(Int, l)
    
    for j = 1:generations-1
        for i = 1:l
            left   = cells[j, mod1(i - 1, l)]
            middle = cells[j, mod1(i, l)]
            right  = cells[j, mod1(i + 1, l)]
            nextgen[i] = totalistic_rule(ruleset, left, middle, right)
        end
        
    cells[j+1,:] = nextgen
    end
    return cells
end
