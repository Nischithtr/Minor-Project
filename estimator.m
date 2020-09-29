function [estimate] = estimator(received_symbol,b_n)
    % Number of sub-carriers
    [~,Nsc] = size(b_n); 

    % QAM constellations
    qam_1 = [(1 + 1i) (-1 - 1i)];
    qam_2 = [(1 + 1i) (1 - 1i) (-1 + 1i) (-1 - 1i)];
    qam_3 = [qam_2 (-3 + 1i) (1 + 3i) (-1 - 3i) (3 - 1i)];
    
    % Valid end points of 32 QAM in first quadrant
    valid_end_points = [5 + 3i ; 3 + 5i];
    
    for ii = 1 : Nsc
        % b_n = 0 maps to 0 + 0i 
        if(b_n(ii) == 0)
            estimate(ii) = 0;
            
         % Estimate is the constellation point closest to received symbol
        elseif (b_n(ii) == 1)
            [~,index] = min(abs(qam_1 - received_symbol(ii)));
            estimate(ii)  = qam_1(index);
            
        % For b_n = 3
        elseif (b_n(ii) == 3)
            [~,index] = min(abs(qam_3 - received_symbol(ii)));
            estimate(ii)  = qam_3(index);
            
        % Similar philosophy used for 2 and higher constellations 
        elseif(b_n(ii) >= 2)
            % Round DOWN the real and and imaginary parts of received symbol  
            real_floor = floor(real(received_symbol(ii)));
            imag_floor = floor(imag(received_symbol(ii)));
            
            % In case the rounded values are even, round it UP
            if (mod(real_floor,2) == 0)
                real_floor = real_floor + 1;
            end
            if (mod(imag_floor,2) == 0)
                imag_floor = imag_floor + 1;
            end
            
            % Add the sum of above results 
            estimate(ii) = real_floor + i * imag_floor;
            
            % These values are bound by a maximum
            if( mod(b_n(ii),2) == 0)
                % The maximum absolute value for 4QAM, 16QAM and 64QAM 
                % are 3,7 and 15 respectively
                % (2 ^ (b_n(ii)/2) - 1) in general
                estimate(ii) = max(min(real(estimate(ii)) , 2 ^ (b_n(ii)/2) - 1) , -(2 ^ (b_n(ii)/2) -1)) + i * max(min(imag(estimate(ii)) , 2 ^ (b_n(ii)/2) - 1) , -(2 ^ (b_n(ii)/2) -1));               
            else
                % The maximum absolute value for 32QAM, 128QAM and 512QAM 
                % are 5,9 and 17 respectively
                % (3 * (2 ^ (b_n(ii) - 3)/2) - 1)) in general
                estimate(ii) = max(min(real(estimate(ii)) , (3 * (2 ^ ((b_n(ii) - 3)/2)) - 1)) , -(3 * (2 ^ ((b_n(ii) - 3)/2)) - 1)) + i * max(min(imag(estimate(ii)) ,(3 * (2 ^ ((b_n(ii) - 3)/2)) - 1)) , -(3 * (2 ^ ((b_n(ii) - 3)/2)) - 1)) ;
                
                % 5 + 5i (with corresponding symbols in other quadrants) is
                % NOT allowed in 32QAM
                % 7 + 7i and higher points is NOT allowed in 128QAM
                % In general,
                %  ((2 ^ ((b_n(ii) - 1)/2)) + 1)) + ((2 ^((b_n(ii) - 1)/2)) + 1)) i and above constellation points are NOT ALLOWED 
                if ((abs(real(estimate(ii))) >= ((2 ^ ((b_n(ii) - 1)/2)) + 1)) && (abs(imag(estimate(ii))) >= ((2 ^ ((b_n(ii) - 1)/2)) + 1)))
                    % valid_end_points captures all the points surrounding
                    % the invalid points in first quadrant
                    valid_end_points_abs = ((2 ^ ((b_n(ii) - 1)/2)) + 1) : 2 : (3 * (2 ^ ((b_n(ii) - 3)/2)));
                    valid_end_points_hor = valid_end_points_abs + i * ((2 ^ ((b_n(ii) - 1)/2)) - 1);
                    valid_end_points_ver = ((2 ^ ((b_n(ii) - 1)/2)) - 1) + i * valid_end_points_abs;
                    valid_end_points = [valid_end_points_hor valid_end_points_ver];
                    
                    % Mapping the valid points to the correct quadrant
                    valid_end_points = real(valid_end_points) .* real(estimate(ii)) ./ abs(real(estimate(ii))) + i * imag(valid_end_points) * imag(estimate(ii)) / abs(imag(estimate(ii)));
                    
                    % Find the end point closest to the received point
                    [~,index] = min(abs(valid_end_points - received_symbol(ii)));
                    estimate(ii) = valid_end_points(index);
                end
            end
        end
    end
end