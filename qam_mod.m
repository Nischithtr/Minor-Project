function [mapped_val] = qam_mod(varargin)
    % data is the data in the buffer
    data = varargin{1};
    
    % b is bit allocation table
    b = varargin{2};
    
    % t is tone allocation table
    t = varargin{3};
    
    % g_array is gain scaling factor
    g_array = varargin{4};
    
    % If trellis coding is to be done  do tone_ordering
    % Otherwise pass the same b and t
    % Peroform bit extraction
    % Trellis coding is incomplete
       
    if(nargin == 5)
        if(strcmp(varargin{5} , 'trellis'))
            [b_n t_n] = tone_order(b,t) 
            extracted_bits = bit_extract(data,b_n,'trellis');
        else
            error('Enter "trellis" label to perform trellis coding') ;
        end
    else
        b_n = b;
        t_n = t;
        extracted_bits = bit_extract(data,b_n); % Extract bits onto the variable based on bit allocation table
    end
    mapped_val = g_array .* constellation_mapper(extracted_bits,b_n); % Convert the extracted bits to QAM symbols
end