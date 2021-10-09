abstract type AbstractCCARule <: AbstractODRule end 

struct CCA{T} <: AbstractCCARule
    rule::T
    radius::Int
end

function CCA(rule; radius=1)
    CCA(rule, radius)
end

function (cca::CCA)(starting_array)

    return nextgen = evolution(starting_array, cca.rule, cca.radius)

end

function c_state_reader(neighborhood, radius)

    return sum(neighborhood)/length(neighborhood)

end

function evolution(cell, rule, radius)

    neighborhood_size = radius*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = modf(c_state_reader(cell[i:i+neighborhood_size-1], radius)+rule)[1]
    end
    
    output
    
end