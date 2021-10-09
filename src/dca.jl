abstract type AbstractDCARule <: AbstractODRule end 

struct DCA{B,R,T} <: AbstractDCARule
    rule::B
    ruleset::R
    states::Int
    radius::T
end

function DCA(rule;
    states=2,
    radius=1)

    ruleset = conversion(rule, states, radius)
        
    DCA(rule, ruleset, states, radius)

end

function (dca::DCA)(starting_array)

    return nextgen = evolution(starting_array, dca.ruleset, dca.states, dca.radius)

end

function conversion(rule, states, radius::Int)

    rule_len = states^(2*radius+1)
    rule_bin = parse.(Int, split(string(rule, base=states), ""))
    rule_bin = vcat(zeros(typeof(rule_bin[1]), rule_len-length(rule_bin)), rule_bin)

    return reverse!(rule_bin)

end

function conversion(rule, states, radius::Tuple)

    rule_len = states^(sum(radius)+1)
    rule_bin = parse.(Int, split(string(rule, base=states), ""))
    rule_bin = vcat(zeros(typeof(rule_bin[1]), rule_len-length(rule_bin)), rule_bin)

    return reverse!(rule_bin)

end

function state_reader(neighborhood, states)

    return parse(Int,join(convert(Array{Int},neighborhood)), base=states)+1 #ugly

end

function evolution(cell, ruleset, states, radius::Int)

    neighborhood_size = radius*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = ruleset[state_reader(cell[i:i+neighborhood_size-1], states)]
    end
    
    output
    
end

function evolution(cell, ruleset, states, radius::Tuple)

    neighborhood_size = sum(radius)+1
    output = zeros(length(cell))#da qui in poi da modificare
    cell = vcat(cell[end-radius[1]+1:end], cell, cell[1:radius[2]])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = ruleset[state_reader(cell[i:i+neighborhood_size-1], states)]
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