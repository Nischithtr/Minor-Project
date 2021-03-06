function [Pt,Pr] = LOS(Nsc,d)
    Pt = 1 / Nsc ; % In milliwatss
    Gt = 1;
    Gr = 8;
    base_freq = 10^3; % Change the power in order to observe change in senitivity wrt frequency
    f = base_freq : 4312.5 : base_freq + 4312.5 * (Nsc-1);
    c = 3 * 10^8 ;
    lambda = c ./ f;
    Pr = Pt * Gt * Gr .* lambda.^2 / (4 * pi * d)^2 ;
    Pr = Pr';
    %Pr_dBm = 10 * log10(Pr) ; 
    %snr = Pr_dBm - 10 * log10(bandwidth);