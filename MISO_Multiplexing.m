clear

nbits = 10^6;
data = randi([0,1],1,nbits) ;

Nsc = 256;
d = 1000;
bandwidth = 4000;
[Pt,Pr] = LOS(Nsc,d);

data_pilot = creverb1(Nsc); % PRBS
bits2persymbol = 2 .* ones(1,256);
g_pilot = ones(1,256);
t_pilot = 1:256;
symbols_sent_pilot1 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);
symbols_sent_pilot2 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

symbols_sent_pilot = [symbols_sent_pilot1 symbols_sent_pilot2];

rayleigh_channel = sqrt(1/2) .* (randn(1,2) + 1i*randn(1,2));% Rayleigh channel added
h = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel;
noise_power_db = -80; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot1 = symbols_sent_pilot1 .* h(:,1);
symbols_received_pilot2 = symbols_sent_pilot2 .* h(:,2);

symbols_received_pilot = [symbols_received_pilot1 symbols_received_pilot2];

estimated_h = (symbols_received_pilot ./ symbols_sent_pilot);
estimated_Pr = (abs(symbols_received_pilot) .^ 2) ./ (abs(symbols_sent_pilot) .^ 2) * Pt;
snr = 10 * log10(estimated_Pr) - noise_power_db - 10 * log10(bandwidth) ;

g_array = zeros(1,Nsc);

fprintf("For noise power of %d Hz/dBm ", noise_power_db);
b_channel1 = basic_fine_gains(snr(:,1)); % Get the adaptive bit loading
b_channel2 = basic_fine_gains(snr(:,2));
g_array1 = [b_channel1.pdiff] ;
g_array2 = [b_channel2.pdiff] ;
bn1 = [b_channel1.nbits_rounded]; % Get only the number of rounded bits in the channel
bn2 = [b_channel2.nbits_rounded]; % Get only the number of rounded bits in the channel
t1 = [b_channel1.channel_id];
t2 = [b_channel2.channel_id];

bit_stream_rcvd = [];

ii = 1;
while (ii <= nbits)
    data_one_pass_t1 = data(ii : min(ii + sum(bn1) - 1 , nbits)) ;
    ii = ii + sum(bn1);
    [QAM_symbols(:,1),b_n_updated_1] = qam_mod(data_one_pass_t1,bn1,t1,g_array1); % QAM symbols
    data_one_pass_t2 = data(ii : min(ii + sum(bn2) - 1 , nbits)) ;
    ii = ii + sum(bn2);
    [QAM_symbols(:,2),b_n_updated_2] = qam_mod(data_one_pass_t2,bn2,t2,g_array2); % QAM symbols
    received_symbols = h .* QAM_symbols + noise ;% QAM symbol + AWGN noise
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,1),b_n_updated_1',g_array1,estimated_h(:,1))]; % Perform demod on the receiver end
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,2),b_n_updated_2',g_array2,estimated_h(:,2))]; % Perform demod on the receiver end
end

err = sum(bit_stream_rcvd ~= data) ./ nbits