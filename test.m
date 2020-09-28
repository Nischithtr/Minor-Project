t=1:256; % Tone loading table not yet used.
snr=SPN_to_SNR_converter(); % Get the SNR table
b=adaptive_fine_gains(snr,1024); % Get the adaptive bit loading
b=[b.nbits_rounded] % Get only the number of rounded bits in the channel
[~,Nsc] = size(b); % Number of sub-carriers
data = creverb1(Nsc); % PRBS
QAM_symbols = qam_mod(data,b,t) % QAM symbols
bit_stream_rcvd = qam_demod(QAM_symbols,b); % Perform demod on the receiver end
data = data(1:sum(b)); % Get the BER
err = sum(bit_stream_rcvd ~= data)