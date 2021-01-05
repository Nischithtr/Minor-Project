clear

n_bits = 10^6;
data = randi([0,1],1,n_bits) ;

Nsc = 256;
d = 1000;
bandwidth = 4000;
[Pt,Pr] = LOS(Nsc,d);
data_pilot = creverb1(Nsc); % PRBS
bits2persymbol = 2 .* ones(1,256);
g_pilot = ones(1,256);
t_pilot = 1:256;
symbols_sent_pilot = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

rayleigh_channel = sqrt(1/2) .* (randn(1) + 1i*randn(1));% Rayleigh channel added
h = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel;
noise_power_db = -80; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot = symbols_sent_pilot .* h;

estimated_Pr = (abs(symbols_received_pilot) .^ 2) ./ (abs(symbols_sent_pilot) .^ 2) * Pt;
estimated_h = (symbols_received_pilot ./ symbols_sent_pilot);
snr = 10 * log10(estimated_Pr) - noise_power_db - 10 * log10(bandwidth) ;

g_array = zeros(1,Nsc);

fprintf("For noise power of %d Hz/dBm ", noise_power_db);
b_channel = basic_fine_gains(snr); % Get the adaptive bit loading
g_array = [b_channel.pdiff] ;
bn = [b_channel.nbits_rounded]; % Get only the number of rounded bits in the channel
t = [b_channel.channel_id];
bit_stream_rcvd = [];

ii = 1;
no_of_times=0;
while (ii <= n_bits)
    data_one_pass = data(ii : min(ii + sum(bn) - 1 , n_bits)) ;
    ii = ii + sum(bn);
    [QAM_symbols,b_n_updated] = qam_mod(data_one_pass,bn,t,g_array); % QAM symbols
    received_symbols = h .* QAM_symbols + noise ;% QAM symbol + AWGN noise``
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols,b_n_updated',g_array,estimated_h)]; % Perform demod on the receiver end
    no_of_times=no_of_times+1;
end

err = sum(bit_stream_rcvd ~= data) ./ n_bits;
fprintf("The bit error rate is %d \n", err);
fprintf("The number of cycles is %d \n", no_of_times); 