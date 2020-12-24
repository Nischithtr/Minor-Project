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

rayleigh_channel_t1 = sqrt(1/2) .* (randn(1,2) + 1i*randn(1,2));
% h11 is first column
% h12 is second column
rayleigh_channel_t2 = sqrt(1/2) .* (randn(1,2) + 1i*randn(1,2));
% h21 is first column
% h22 is second column
h1 = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel_t1;
h2 = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel_t2;
h1_abs = abs(h1);
h2_abs = abs(h2);
[~, max_pos1]=max(h1_abs, [], 2);
[~, max_pos2]=max(h2_abs, [], 2);
h_selected1 = zeros(256,1);
h_selected2 = zeros(256,1);
for ii = 1 : Nsc
    h_selected1(ii,1) = h1(ii,max_pos1(ii));
    h_selected2(ii,1) = h2(ii,max_pos2(ii));
end
h_selected = [h_selected1 h_selected2];

noise_power_db = -80; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot1_r1 = symbols_sent_pilot1 .* h1(:,1);
symbols_received_pilot1_r2 = symbols_sent_pilot2 .* h1(:,2);
symbols_received_pilot2_r1 = symbols_sent_pilot2 .* h2(:,1);
symbols_received_pilot2_r2 = symbols_sent_pilot2 .* h2(:,2);

symbols_received_pilot1 = [symbols_received_pilot1_r1 symbols_received_pilot1_r2];
symbols_received_pilot2 = [symbols_received_pilot2_r1 symbols_received_pilot2_r2];

estimated_h_inc1 = (symbols_received_pilot1 ./ symbols_sent_pilot1);
estimated_h_inc2 = (symbols_received_pilot2 ./ symbols_sent_pilot2);
[estimated_h1, max_pos1] = max(estimated_h_inc1, [], 2);
[estimated_h2, max_pos2] = max(estimated_h_inc2, [], 2);
for ii = 1 : Nsc
    symbols_received_pilot_selected1(ii) = symbols_received_pilot1(ii,max_pos1(ii));
    symbols_received_pilot_selected2(ii) = symbols_received_pilot2(ii,max_pos2(ii));
end
symbols_received_pilot_selected1 = symbols_received_pilot_selected1';
symbols_received_pilot_selected2 = symbols_received_pilot_selected2';
estimated_Pr1 = (abs(symbols_received_pilot_selected1) .^ 2) ./ (abs(symbols_sent_pilot1) .^ 2) * Pt;
estimated_Pr2 = (abs(symbols_received_pilot_selected2) .^ 2) ./ (abs(symbols_sent_pilot2) .^ 2) * Pt;
snr1 = 10 * log10(estimated_Pr1) - noise_power_db - 10 * log10(bandwidth) ;
snr2 = 10 * log10(estimated_Pr2) - noise_power_db - 10 * log10(bandwidth) ;

g_array = zeros(1,Nsc);
bit_stream_rcvd = [];

fprintf("For noise power of %d Hz/dBm ", noise_power_db);
b_channel1 = basic_fine_gains(snr1); % Get the adaptive bit loading
b_channel2 = basic_fine_gains(snr2);
g_array1 = [b_channel1.pdiff] ;
g_array2 = [b_channel2.pdiff] ;
bn1 = [b_channel1.nbits_rounded]; % Get only the number of rounded bits in the channel
bn2 = [b_channel2.nbits_rounded]; % Get only the number of rounded bits in the channel
t1 = [b_channel1.channel_id];
t2 = [b_channel2.channel_id];

ii = 1;
number_of_times = 0;
while (ii <= n_bits)
    data_one_pass_t1 = data(ii : min(ii + sum(bn1) - 1 , n_bits)) ;
    ii = ii + sum(bn1);
    [QAM_symbols(:,1),b_n_updated_1] = qam_mod(data_one_pass_t1,bn1,t1,g_array1); % QAM symbols
    data_one_pass_t2 = data(ii : min(ii + sum(bn2) - 1 , n_bits)) ;
    ii = ii + sum(bn2);
    [QAM_symbols(:,2),b_n_updated_2] = qam_mod(data_one_pass_t2,bn2,t2,g_array2); % QAM symbols
    received_symbols = h_selected .* QAM_symbols + noise ;% QAM symbol + AWGN noise
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,1),b_n_updated_1',g_array1,estimated_h1)]; % Perform demod on the receiver end
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,2),b_n_updated_2',g_array2,estimated_h2)]; % Perform demod on the receiver end
    number_of_times = number_of_times + 1;
end

err = sum(bit_stream_rcvd ~= data) ./ n_bits
fprintf(" Time taken = %d t1 \n" , number_of_times);