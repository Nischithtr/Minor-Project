clc;
nsc=7; % Number of Sub Channels
for i=1:1:4*nsc
    rand_num = psbr(i, nsc);
    disp(i+"="+rand_num)
end
