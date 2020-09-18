%Function is defined as per CREVERB1 standard provided by ITU standard

function rand_num = psbr(n , nsc)
    if(n>=1 && n<=9)
        rand_num=1;
    elseif(n>=10 && n<=2*nsc)
        rand_num = bitxor(psbr(n-4, nsc), psbr(n-9, nsc));
    elseif(n==2*nsc+1 || n==2*nsc+2)
        rand_num = psbr(n-2*nsc, nsc);
    elseif(n>=2*nsc+3 && n<=4*nsc)
        if(mod(n, 2)==1)
            rand_num = psbr(4*nsc+2-n, nsc);
        else
            rand_num = bitxor(1,psbr(4*nsc+4-n, nsc));
        end
    end
    