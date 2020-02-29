 
mutable struct dCA
    rule::Integer
    ruleset::Array{Integer}
    states::Integer
    radius::Integer
    cells::Matrix{Integer}
    
    function dCA(rule::Integer, 
            starting_val::Array{Integer}, 
            generations::Integer = 100,
            states::Integer = 2, 
            radius::Integer=1)
        
        ncells = length(starting_val)
        cells = zeros(Integer, generations, ncells)
        cells[1,:] = starting_val
        ruleset = conversion(rule, states, states)
        
        if states == 2
            cells = next_gen!(cells, generations, ruleset)
        else 
            cells = totalistic_next_gen!(cells, generations, ruleset)
        end
        
        new(rule, ruleset, states, radius, cells)
    end
end

function conversion(bin::Integer, 
        states::Integer, 
        radius::Integer)
    
    if states == 2
        bin_array = zeros(Integer, states^(2*radius+1))
        for i=states^(2*radius+1):-1:1
            bin_array[i] = bin % states
            bin = floor(bin/states)
        end
    else
        bin_array = zeros(Integer, (2*radius+1)*states-2)
        for i=(2*radius+1)*states-2:-1:1
            bin_array[i] = bin % states
            bin = floor(bin/states)
        end
    end
    return bin_array
end

function rules(ruleset::Array{Integer}, 
        left::Integer, 
        middle::Integer,
        right::Integer)
    
    lng = length(ruleset)
    return ruleset[mod1(lng-(4*left + 2*middle + right), lng)]
end

function totalistic_rule(ruleset::Array{Integer}, 
        left::Integer, 
        middle::Integer,
        right::Integer)
    
    lng = length(ruleset)
    return ruleset[mod1(lng-(left + middle + right), lng)]
end

function next_gen!(cells::Matrix{Integer}, 
        generations::Integer,
        ruleset::Array{Integer})
     
    l = size(cells)[2]
    nextgen = zeros(Integer, l)
    
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

function totalistic_next_gen!(cells::Matrix{Integer}, 
        generations::Integer,
        ruleset::Array{Integer})
    
    l = size(cells)[2]
    nextgen = zeros(Integer, l)
    
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
