function [rand_num] = creverb1(nsc)
    rand_num = [];
    % Generate and store 4Nsc random numbers
    for i=1:1:4*nsc
        rand_num = [rand_num prbs(i, nsc)];
    end
end