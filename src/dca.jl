mutable struct DCA{R, S}
    rule::Int
    ruleset::R
    states::Int
    radius::Int
    cells::S
end

function DCA(rule, starting_array; 
    generations=100,
    states=2, 
    radius=1)

    ncells = length(starting_array)
    cells = zeros(typeof(starting_array[1]), generations, ncells)
    cells[1,:] = starting_array
    ruleset = conversion(rule, states, radius)

    if states == 2
        cells = disc_next_gen!(cells, generations, ruleset)
    else 
        cells = tot_disc_next_gen!(cells, generations, ruleset)
    end

    DCA(rule, ruleset, states, radius, cells)

end

function conversion(bin, states, radius)
    
    if states == 2
        bin_array = zeros(Bool, states^(2*radius+1))
        for i=states^(2*radius+1):-1:1
            bin_array[i] = bin % states
            bin = floor(bin/states)
        end
    else
        bin_array = zeros((2*radius+1)*states-2)
        for i=(2*radius+1)*states-2:-1:1
            bin_array[i] = bin % states
            bin = floor(bin/states)
        end
    end

    return bin_array

end

function rules(ruleset, left, middle, right)
    
    lng = length(ruleset)
    return ruleset[mod1(lng-(4*left + 2*middle + right), lng)]

end

function totalistic_rule(ruleset, left, middle, right)

    lng = length(ruleset)
    return ruleset[mod1(lng-(left + middle + right), lng)]

end

function disc_next_gen!(cells, generations, ruleset)
     
    l = size(cells)[2]
    nextgen = zeros(typeof(cells[1]), l)
    
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

function tot_disc_next_gen!(cells, generations, ruleset)
    
    l = size(cells)[2]
    nextgen = zeros(typeof(cells[1]), l)
    
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
