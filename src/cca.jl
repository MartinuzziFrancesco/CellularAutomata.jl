struct CCA{T}
    rule::T
    radius::Int
end

""" 
    TCA(code; radius=1)

Returns a ```CCA``` object given a specific code and radius. 
"""
function CCA(rule; radius=1)
    CCA(rule, radius)
end

function (cca::CCA)(starting_array)

    nextgen = evolution(starting_array, cca.rule, cca.radius)
end

function c_state_reader(neighborhood, radius)

    sum(neighborhood)/length(neighborhood)
end

function evolution(cell, rule, radius::Number)

    neighborhood_size = radius*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = modf(c_state_reader(cell[i:i+neighborhood_size-1], radius)+rule)[1]
    end
    
    output
end

function evolution(cell, rule, radius::Tuple)

    neighborhood_size = sum(radius)+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = modf(c_state_reader(cell[i:i+neighborhood_size-1], radius)+rule)[1]
    end
    
    output
end