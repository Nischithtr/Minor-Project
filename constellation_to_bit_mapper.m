function [bit_stream] = constellation_to_bit_mapper(estimate,b_n)
    % Number of sub-carriers
    [~,Nsc] = size(b_n); 
    % Initialize bit stream
    bit_stream = [];
    
    % Going to  4n constellation point
    goto4n = [0 -2i -2 -(2 + 2i)];
 
    % 4n matrix
    transform_matrix = [0 2i 2 (2 + 2i)];


    % QAM constellations
    qam_1 = [(1 + 1i) (-1 - 1i)];
    qam_2 = [(1 + 1i) (1 - 1i) (-1 + 1i) (-1 - 1i)];
    qam_3 = [qam_2 (-3 + 1i) (1 + 3i) (-1 - 3i) (3 - 1i)];
    qam_5 = [(1 + 1i) (1 + 3i) (3 + 1i) (3 + 3i) (1 - 3i) (1 - 1i) (3 - 3i) (3 - 1i) (-3 + 1i) (-3 + 3i) (-1 + 1i) (-1 + 3i) (-3 - 3i) (-3 - 1i) (-1 - 3i) (-1 - 1i) (5 + 1i) (5 + 3i) (-5 + 1i) (-5 + 3i) (1 + 5i) (1 - 5i) (3 + 5i) (3 - 5i) (-3 + 5i) (-3 - 5i) (-1 + 5i) (-1 -5i) (5 - 3i) (5 - 1i) (-5 -3i) (-5 - 1i)]; % QAM constellation of symobols corresponding to 16 - 3
    
    for ii = 1 : Nsc
        % Find the index corresponding to estimate and convert it to binary 
        if (b_n(ii) == 1)
            index = find(qam_1 == estimate(ii));
            symbol{ii} = index - 1;
            
        % Similar operation for b_n = 3
        elseif (b_n(ii) == 3)
            index = find(qam_3 == estimate(ii));
            symbol{ii} = de2bi(index - 1 , 3 , 'left-msb');
            
        % For even b_n > 2 and odd b_n > 5 , decode 2 bits at a time    
        elseif (b_n(ii) >= 2)
            % Initialize
            symbol{ii} = [];
            
            % Fix the number of times to run the loop
            if(mod(b_n(ii),2) == 0)
                loop_end = b_n(ii) / 2 - 1;
            else
                loop_end = (b_n(ii) - 3) / 2 - 1;
            end
            
            % Get the first 4n point of the quadrant
            basic_quadrant_point = real(estimate(ii)) / abs(real(estimate(ii))) + 1i * imag(estimate(ii)) / abs(imag(estimate(ii)));
            basic_quadrant_point = basic_quadrant_point + goto4n(qam_2 == basic_quadrant_point);
            
            % Run the loop
            for jj = 1 : loop_end
                % Offset from 4n point is captured in diff
                diff = mod(real(estimate(ii)) - real(basic_quadrant_point),4) + 1i *  (mod(imag(estimate(ii)) - imag(basic_quadrant_point),4));
                
                % Get the corresponding binary value
                bin_val = de2bi(find(transform_matrix == diff) - 1,2,'left-msb');
                
                % Populate the symbol
                symbol{ii} = [bin_val  symbol{ii}];
                
                % Go to n/4  point
                estimate(ii) = (estimate(ii) - diff + 1 + 1i) / 2;
            end
            
            % The MSB of even constellation are 2 bits from 2QAM
            % constellation
            if(mod(b_n(ii),2) == 0 && b_n(ii) > 0)
                bin_val = de2bi(find(qam_2 == estimate(ii)) - 1,2,'left-msb');
                symbol{ii} = [bin_val  symbol{ii}];
            % The MSB of odd constellation are 5 bits from 32QAM
            % constellation
            elseif(b_n(ii) > 0)
                bin_val = de2bi(find(qam_5 == estimate(ii)) - 1,5,'left-msb');
                symbol{ii} = [bin_val  symbol{ii}];
            end
        end
        
        % Populate the bit_stream
        if (b_n(ii) ~= 0)
            bit_stream = [bit_stream symbol{ii}];
        end
    end
end