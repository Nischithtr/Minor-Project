function [mapped] = constellation_mapper(extracted_bits,b_n)
    % Number of sub-carriers
    [~,Nsc] = size(b_n); 
    
    % Initialization of mapped vector
    mapped = zeros(Nsc,1);
    
    % QAM constellations
    qam_1 = [(1 + i) (-1 - i)];
    qam_2 = [(1 + i) (1 - i) (-1 + i) (-1 - i)];
    qam_3 = [qam_2 (-3 + i) (1 + 3i) (-1 - 3i) (3 - i)];
    qam_5_part = [(5 + i) (5 + 3i) (-5 + i) (-5 + 3i) (1 + 5i) (1 - 5i) (3 + 5i) (3 - 5i) (-3 + 5i) (-3 - 5i) (-1 + 5i) (-1 -5i) (5 - 3i) (5 - i) (-5 -3i) (-5 - i)]; % QAM constellation of symobols corresponding to 16 - 31
    qam_5_to_qam_2 = [[0 ; 0] [0 ; 0] [1 ; 0] [1 ; 0] [0 ; 0] [0 ; 1] [0 ; 0] [0 ; 1] [1 ; 0] [1 ; 1] [1 ; 0] [1; 1] [0 ; 1] [0 ; 1] [1 ; 1] [1 ; 1]]; 
    % Vectors which tell the quadrant to which each of these symbols (16 - 31) belong
    % 00 - 1st quadrant
    % 10 - 2nd quadrant
    % 11 - 3rd quadrant
    % 01 - 4th quadrant

    % Going to  4n constellation point
    goto4n = [0 -2i -2 -(2 + 2i)];
    
    % 4n matrix
    transform_matrix = [0 2i 2 (2 + 2i)];
    
    % generating QAM symbol
    for ii = 1 : Nsc 
        recursion_reqd = 0;
        if (b_n(ii) == 1)
            mapped_symbol = qam_1(extracted_bits{ii} + 1); % Number of bits  = 1 case
        elseif (mod(b_n(ii),2) == 0 & b_n(ii)>0)
            reordered_bin = reshape(extracted_bits{ii},2,b_n(ii) / 2); % separate into set of 2 symbols
            reordered_dec = bi2de(reordered_bin','left-msb'); % Decimal value corresponding to reordered bits
            mapped_symbol = qam_2(reordered_dec(1) + 1); % Map first value to qam symbol
            recursion_reqd = 1; % Absolutely required when b_n = 4,6,8,....
        elseif(mod(b_n(ii),2) == 1 )
            mapped_symbol = qam_3(bi2de((extracted_bits{ii}(1:3)'),'left-msb') + 1); % Map first 3 bits to qam_3 symbol 
            if(b_n(ii) > 3)
                reordered_bin = reshape(extracted_bits{ii}(4:end),2,(b_n(ii) - 3) / 2);
                if (bi2de((extracted_bits{ii}(1:3)'),'left-msb') < 4)
                    % Symbols 1 - 15 in 32 qam corresponds to 16 qam constellation.
                    % Hence, we could take second and third bit and repeat the
                    % process used for even constelltions     
                    reordered_bin = [extracted_bits{ii}(2:3) reordered_bin];
                    reordered_dec = bi2de(reordered_bin','left-msb');
                    recursion_reqd = 1;
                else
                    % Symbol 15 - 31 is taken from the constellation
                    % defined
                    % Choosing the correct quadrant using qam_5_to_qam_2
                    % and reapeatig the process used for even constellation
                    mapped_symbol = qam_5_part(bi2de((extracted_bits{ii}(1:5)'),'left-msb') - 15);
                    reordered_bin(:,1) = qam_5_to_qam_2(:,bi2de((extracted_bits{ii}(1:5)'),'left-msb') - 15);
                    reordered_dec = bi2de(reordered_bin','left-msb');
                    recursion_reqd = 1;
                end
            end
        end
        if (recursion_reqd)
            for jj = 2 : size(reordered_dec)
                % (2 * mapped_symbol - qam_2(reordered_dec(1) + 1)) takes
                % care of necessary shifting
                % goto4n(reordered_dec(1) + 1) takes to 4n point
                % transform_matrix(reordered_dec(jj) + 1) takes care of
                % moving to the desired point from 4n point
                mapped_symbol = (2 * mapped_symbol - qam_2(reordered_dec(1) + 1)) + goto4n(reordered_dec(1) + 1) + transform_matrix(reordered_dec(jj) + 1);  % From the given point shift by appropriate anoumt, go to 4n point, then move to appropriate point 
            end
        end
        if(b_n(ii) > 0)
            mapped(ii) = mapped_symbol;
        end
    end
end