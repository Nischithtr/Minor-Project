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
symbols_sent_pilot1 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);
symbols_sent_pilot2 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

symbols_sent_pilot = [symbols_sent_pilot1 symbols_sent_pilot2];

rayleigh_channel = sqrt(1/2) .* (randn(1,4) + 1i*randn(1,4));
% h11 is first column
% h12 is second column
% h21 is third column
% h22 is fourth column
h = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel;
h_abs = abs(h);
[~, max_pos]=max(h_abs, [], 2);
h_selected = zeros(256,1);
for ii = 1 : Nsc
    h_selected(ii,1) = h(ii,max_pos(ii));
end

noise_power_db = -80; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot1_r1 = symbols_sent_pilot1 .* h(:,1);
symbols_received_pilot1_r2 = symbols_sent_pilot2 .* h(:,2);
symbols_received_pilot2_r1 = symbols_sent_pilot2 .* h(:,3);
symbols_received_pilot2_r2 = symbols_sent_pilot2 .* h(:,4);

symbols_received_pilot = [symbols_received_pilot1_r1 symbols_received_pilot1_r2 symbols_received_pilot2_r1 symbols_received_pilot2_r2];

estimated_h_inc = (symbols_received_pilot ./ symbols_sent_pilot1);
[estimated_h, max_pos] = max(estimated_h_inc, [], 2);
for ii = 1 : Nsc
    symbols_received_pilot_selected(ii) = symbols_received_pilot(ii,max_pos(ii));
end
symbols_received_pilot_selected = symbols_received_pilot_selected';
estimated_Pr = (abs(symbols_received_pilot_selected) .^ 2) ./ (abs(symbols_sent_pilot1) .^ 2) * Pt;
snr = 10 * log10(estimated_Pr) - noise_power_db - 10 * log10(bandwidth) ;

g_array = zeros(1,Nsc);
bit_stream_rcvd = [];

fprintf("For noise power of %d Hz/dBm ", noise_power_db);
b_channel = basic_fine_gains(snr); % Get the adaptive bit loading
g_array=[b_channel.pdiff] ;
bn=[b_channel.nbits_rounded]; % Get only the number of rounded bits in the channel
t = [b_channel.channel_id];

ii = 1;
number_of_times = 0;
while (ii <= n_bits)
    data_one_pass = data(ii : min(ii + sum(bn) - 1 , n_bits)) ;
    ii = ii + sum(bn);
    [QAM_symbols,b_n_updated] = qam_mod(data_one_pass,bn,t,g_array); % QAM symbols
    received_symbols = h_selected .* QAM_symbols + noise ;% QAM symbol + AWGN noise``
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols,b_n_updated',g_array,estimated_h)]; % Perform demod on the receiver end
    number_of_times = number_of_times + 1;
end

err = sum(bit_stream_rcvd ~= data) ./ n_bits
fprintf(" Time taken = %d t \n" , number_of_times);