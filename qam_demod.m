function bit_stream = qam_demod(received_symbols , b_n)
    % Estimate the symbol
    estimate = estimator(received_symbols,b_n);

    % Map theconstellation to bits
    bit_stream = constellation_to_bit_mapper(estimate,b_n) ;   
end