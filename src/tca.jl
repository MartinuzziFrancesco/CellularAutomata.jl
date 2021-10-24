abstract type AbstractTCARule <: AbstractDCARule end 

struct TCA{B,R,T} <: AbstractTCARule
    code::B
    codeset::R
    states::Int
    radius::T
end

""" 
    TCA(code; states=2, radius=1)

Returns a ```TCA``` object given a specific code, number of states and radius. The ruleset for the rule is computed and 
stored in the struct as well.
"""
function TCA(code;
    states=2,
    radius=1)

    codeset = tca_conversion(code, states, radius)
    TCA(code, codeset, states, radius)
end

"""
    (tca::TCA)(starting_array)

Returns the next state of the given ```starting_array``` according to the evolution rule contained in the ```TCA``` struct.
"""
function (tca::TCA)(starting_array)

    nextgen = tca_evolution(starting_array, tca.codeset, tca.states, tca.radius)
end

function tca_conversion(code, states, radius::Number)

    code_len = (2*radius+1)*states-2
    code_bin = parse.(Int, split(string(code, base=states), ""))
    code_bin = vcat(zeros(typeof(code_bin[1]), code_len-length(code_bin)), code_bin)
    reverse!(code_bin)
end

function tca_conversion(code, states, radius::Tuple)

    code_len = (sum(radius)+1)*states-2
    code_bin = parse.(Int, split(string(code, base=states), ""))
    code_bin = vcat(zeros(typeof(code_bin[1]), code_len-length(code_bin)), code_bin)
    reverse!(code_bin)
end

function tca_state_reader(neighborhood, codeset_len)

    mod1(sum(neighborhood)+1,codeset_len)
end

function tca_evolution(cell, codeset, states, radius::Number)

    neighborhood_size = radius*2+1
    output = zeros(length(cell))
    cell = vcat(cell[end-neighborhood_size÷2+1:end], cell, cell[1:neighborhood_size÷2])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = codeset[tca_state_reader(cell[i:i+neighborhood_size-1], length(codeset))]
    end
    
    output  
end

function tca_evolution(cell, codeset, states, radius::Tuple)

    neighborhood_size = sum(radius)+1
    output = zeros(length(cell))
    cell = vcat(cell[end-radius[1]+1:end], cell, cell[1:radius[2]])
    
    for i=1:length(cell)-neighborhood_size+1
        output[i] = codeset[tca_state_reader(cell[i:i+neighborhood_size-1], length(codeset))]
    end
    
    output
end