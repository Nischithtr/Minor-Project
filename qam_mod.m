function [mapped_val,b_n_updated] = qam_mod(data,b,t,g_array)
    b_n = b;
    t_n = t;
    [extracted_bits , b_n_updated] = bit_extract(data,b_n,t);% Extract bits onto the variable based on bit allocation table
    mapped_val = g_array' .* constellation_mapper(extracted_bits,b_n_updated'); % Convert the extracted bits to QAM symbols
end