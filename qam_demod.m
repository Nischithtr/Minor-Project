function bit_stream = qam_demod(received_symbols , b_n,g_array,estimated_h)
    % Estimate the symbol
    estimate = estimator(received_symbols ./ g_array' ./ estimated_h,b_n);

    % Map theconstellation to bits
    bit_stream = constellation_to_bit_mapper(estimate,b_n) ;   
end