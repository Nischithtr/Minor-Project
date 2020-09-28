function extracted_bits = bit_extract(varargin)
    % The data in buffer
    data = varargin{1};
    
    % b_n is the new bit allocation table
    b_n = varargin{2};
    
    % Number of sub-carriers
    [~,Nsc]  = size(b_n);
    
    % Data indexer
    k = 1;
    
    % For trellis coding
    % Will add comments once completed
    if(nargin == 3)
        for ii = 1 : 2 : Nsc - 5
            x = b_n(ii);
            y = b_n(ii + 1);
            if ((x > 1) &&  (y>1))
               extracted_bits{(ii+1)/2} = (data(k : k + x + y -1))' ;
            elseif ((x == 0) && (y>1))
               extracted_bits{(ii+1)/2} = [(data(k : k + x + y -2)) 0 data(k + x + y - 1) 0]' ;
            elseif (((x ==1) && (y >= 1)) || ((x == 0) && (y == 1)))
               error("Tone ordering error or odd number of single bit carriers"); 
            end
            k = k + x + y ;
        end
        for ii = Nsc - 5 : 2 : Nsc - 1
            x = b_n(ii);
            y = b_n(ii + 1);
            if ((x > 1) &&  (y>1))
               extracted_bits{(ii+1)/2} = [(data(k : k + x + y -3)) 0 0]' ;
               k = k + x + y -2;
            elseif ((x == 0) && (y>1))
               extracted_bits{(ii+1)/2} = [(data(k : k + x + y -2)) 0 data(k + x + y - 1) 0]' ;
               k = x + y;
            elseif (((x ==1) && (y >= 1)) || ((x == 0) && (y == 1)))
               error("Tone ordering error or odd number of single bit carriers"); 
            end
        end
    else
        for ii = 1 : Nsc
            extracted_bits{ii} = (data(k : k + b_n(ii) - 1))'; % This is being used
            k = k + b_n(ii); %Incrementing k by b_n bits
        end
    end
end