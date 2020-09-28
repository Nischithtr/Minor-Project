function [b_n t_n] = tone_order(b,t)
    % Initializing blank rows
    t_n = [];
    t_n2 = [];
    
    % Finding number of sub-carriers
    [~,Nsc] = size(b);
    
    % Pushing all t's whose corresponding b's are 1 to end
    for ii = 1 : Nsc
        if b(ii) ~= 1
            t_n = [t_n t(ii)];
        else
            t_n2 = [t_n2 t(ii)];
        end
    end
    t_n = [t_n t_n2];
    
    % Find number of loaded sub-carriers
    ncused  = sum(b>0);
    
    % Find number of single bit carriers
    [~,nconebit] = size(t_n2);
    
    % First nconebit/2 + (Nsc - ncused) bits of b_n are zeros 
    % The value b0' is prepended to the reordered bit table b' to make an integer number of pairs and shall be set to 0. 
    b_n = zeros(1 , Nsc - ncused + nconebit / 2 + 1);
    
    % Next are multi bit carriers 
    for ii = 1 : Nsc 
        bit = b(t_n(ii)) ;
        if(bit > 1)
            b_n = [b_n bit] ; 
        end
    end
    
    % last nconebit/2 2's (pair of ones)
    b_n = [b_n (2 .* ones(1,nconebit/2))]; 
end