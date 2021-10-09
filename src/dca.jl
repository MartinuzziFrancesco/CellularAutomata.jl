abstract type AbstractDCARule <: AbstractODRule end 

struct DCA{R} <: AbstractDCARule
    rule::Int
    ruleset::R
    states::Int
    radius::Int
end

struct ECA{R} <: AbstractDCARule
    rule::Int
    ruleset::R
end

function DCA(rule;
    states=2,
    radius=1)

    #ruleset = conversion(rule, states, radius) maybe?

    if states == 2 && radius == 1
        ruleset = conversion(rule)
        return ECA(rule, ruleset)
    else
        ruleset = conversion(rule, states, radius)
        return DCA(rule, ruleset, states, radius)
    end

end

function (dca::DCA)(starting_array)

    return nextgen = evolution(starting_array, dca.ruleset, dca.states, dca.radius)

end

function (eca::ECA)(starting_array)

    return nextgen = evolution(starting_array, eca.ruleset)

end


function conversion(rule)
    
    rule_len = 2^(2*1+1) #states^(radius*1+1) ?
    rule_bin = parse.(Int, split(string(rule, base=2), ""))
    rule_bin = vcat(zeros(typeof(rule_bin[1]), rule_len-length(rule_bin)), rule_bin)

    return reverse!(rule_bin)

end


function conversion(rule, states, radius)

    rule_len=(2*radius+1)*states-2
    rule_bin = parse.(Int, split(string(rule, base=states), ""))
    rule_bin = vcat(zeros(typeof(rule_bin[1]), rule_len-length(rule_bin)), rule_bin)

    return reverse!(rule_bin)

end

function state_reader(neighborhood, ruleset_len)

    return mod1(sum(neighborhood)+1,ruleset_len)

end

function state_reader(neighborhood)

    return parse(Int,join(convert(Array{Int},neighborhood)), base=2)+1 #ugly

end

function evolution(cell, ruleset, states, radius)

    neighborhood_size = radius*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = ruleset[state_reader(cell[i:i+neighborhood_size-1], length(ruleset))]
    end
    
    output
    
end

function evolution(cell, ruleset)

    neighborhood_size = 1*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = ruleset[state_reader(cell[i:i+neighborhood_size-1])]
    end
    
    output
    
end

#consider (single function, less lines)
#=
function evolution(cell, ruleset, args...)

    neighborhood_size = radius*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = ruleset[state_reader(cell[i:i+neighborhood_size-1], args...)+1]
    end
    
    output
    
end
=#