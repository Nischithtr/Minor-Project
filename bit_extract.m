function [extracted_bits , b_n_updated] = bit_extract(data,b_n,t)
    % Number of sub-carriers
    [~,Nsc]  = size(b_n);
    
    % Data indexer
    k = 1;
    
    %Data size
    [~,data_length] = size(data); 
    
    for ii = 1 : Nsc
            extracted_bits{ii} = (data(k : min((k + b_n(t(ii)) - 1) , data_length)))';
            if k + b_n(ii) > data_length
                b_n_updated(ii) = data_length - k + 1;
                b_n_updated(ii + 1 : Nsc) = 0; 
                break
            end
            b_n_updated(ii) = b_n(ii);
            k = k + b_n(ii);
    end
    b_n_updated = b_n_updated';
end