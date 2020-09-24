%Function is defined as per CREVERB1 standard provided by ITU standard
function rand_num = prbs(n , nsc, buffer)
    if(n>=1 && n<=9)
        rand_num=1; % For n = 1 to 9 , random number is 1
    elseif(n>=10 && n<=2*nsc)
        rand_num = bitxor(buffer(n-4), buffer(n-9));
    elseif(n==2*nsc+1 || n==2*nsc+2)
        rand_num=buffer(n-2*nsc);
    elseif(n>=2*nsc+3 && n<=4*nsc)
        if(mod(n, 2)==1)
            rand_num=buffer(4*nsc+2-n);
        else
            rand_num=bitxor(1, buffer(4*nsc+4-n));
        end
    end
    