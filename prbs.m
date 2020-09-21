%Function is defined as per CREVERB1 standard provided by ITU standard

function rand_num = prbs(n , nsc)
    if(n>=1 && n<=9)
        rand_num=1; % For n = 1 to 9 , random number is 1
    elseif(n>=10 && n<=2*nsc)
        rand_num = bitxor(prbs(n-4, nsc), prbs(n-9, nsc)); % For n = 10 to 2*Nsc , random number is d(n-4) xor d(n-9)
    elseif(n==2*nsc+1 || n==2*nsc+2)
        rand_num = prbs(n-2*nsc, nsc); % For n = 2Nsc + 1 to 2Nsc + 2 , random number is d(n - 2Nsc)
    elseif(n>=2*nsc+3 && n<=4*nsc)
        if(mod(n, 2)==1)
            rand_num = prbs(4*nsc+2-n, nsc); % For odd n > 2Nsc + 2 , random number is d(4Nsc + 2 -n) 
        else
            rand_num = bitxor(1,prbs(4*nsc+4-n, nsc)); % For even n > 2Nsc + 2 , random number is 1 xor d(4Nsc + 4 -n)
        end
    end
    