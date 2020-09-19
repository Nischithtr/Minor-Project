function [rand_num] = creverb1(nsc)
    rand_num = [];
    for i=1:1:4*nsc
        rand_num = [rand_num psbr(i, nsc)];
    end
end