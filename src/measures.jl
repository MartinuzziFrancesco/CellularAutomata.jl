function lempel_ziv_complexity(sequence)
    sub_strings = Set()
    n = length(sequence)

    ind = 1
    inc = 1
    while true
        if ind + inc > n
            break
        end
        sub_str = sequence[ind : ind + inc]
        if sub_str in sub_strings
            inc += 1
        else
            push!(sub_strings, sub_str)
            ind += inc
            inc = 1
        end
    end
    return length(sub_strings)
end

function lempel_ziv(ca::AbstractCA)
    ca_size = size(ca.evolution, 1)
    lz_tot = 0
    
    for i=1:ca_size
        lz_tot += lempel_ziv_complexity(ca.evolution[i,:])
    end
    lz_tot/ca_size
end