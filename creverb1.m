function [rand_num] = creverb1(nsc)
    clc
    rand_num = zeros(1, 4*nsc);
    buffer = zeros(1, 2*nsc);
    for i=1:2*nsc
        buffer(i)=-1;
    end
    % Generate and store 2Nsc random numbers
    for i=1:2*nsc
        rand_num(i) = prbs(i, nsc, buffer);
        if(i<=2*nsc)
            buffer(i)= rand_num(i);
        end
    end
end