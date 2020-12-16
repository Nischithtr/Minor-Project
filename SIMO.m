clear
t=1:256; % Tone loading table not yet used.
Nsc = 256;
d = 1000;
bandwidth = 4000;
[Pt,Pr] = LOS(Nsc,d);
data_pilot = creverb1(Nsc); % PRBS
bits2persymbol = 2 .* ones(256,1);
g_pilot = ones(1,256);
symbols_sent_pilot = qam_mod(data_pilot , bits2persymbol,t,g_pilot);

rayleigh_channel = sqrt(1/2) .* (randn(1) + 1i*randn(1,2));% Rayleigh channel added
h = Pr ./ Pt * rayleigh_channel;
h=abs(h);
[h_selected, max_pos]=max(h, [], 2);
noise_power_db = -140 : 10 : 30; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot = symbols_sent_pilot .* Pr / Pt * rayleigh_channel;
[symbols_received_pilot_selected, max_pos] = max(symbols_received_pilot, [], 2);
estimated_Pr = (abs(symbols_received_pilot_selected) .^ 2) ./ (abs(symbols_sent_pilot) .^ 2) * Pt;
estimated_h = (symbols_received_pilot_selected ./ symbols_sent_pilot);
snr = 10 * log10(estimated_Pr) - noise_power_db - 10 * log10(bandwidth) ;

len_noise_array=length(noise_power_db);

g_array = zeros(len_noise_array,Nsc);
data = cell(1,len_noise_array);
received_symbols = zeros(256,len_noise_array);
bit_stream_rcvd = cell(1,len_noise_array);

for ii = 1:len_noise_array
    fprintf("For noise power of %d Hz/dBm ", noise_power_db(ii));
    b_channel(ii,:) = basic_fine_gains(snr(:,ii)); % Get the adaptive bit loading
    g_array(ii,:)=[b_channel(ii,:).pdiff] ;
    bn(ii,:)=[b_channel(ii,:).nbits_rounded]; % Get only the number of rounded bits in the channel
    data{:,ii} = randi([0,1],1,sum(bn(ii,:))) ;
    QAM_symbols(:,ii) = qam_mod(data{:,ii},bn(ii,:),t,g_array(ii,:)); % QAM symbols
    received_symbols(:,ii) = h_selected .* QAM_symbols(:,ii) + noise(ii);% QAM symbol + AWGN noise``
    bit_stream_rcvd{:,ii} = qam_demod(received_symbols(:,ii),bn(ii,:),g_array(ii,:),estimated_h); % Perform demod on the receiver end
    err(ii) = sum(bit_stream_rcvd{:,ii} ~= data{:,ii}) ./ sum(bn(ii,:));
end

% Plot of BER vs SNR
figure(2)
plot( noise_power_db,err)
title("BER vs noise power ")
xlabel("Noise power")
ylabel("BER")

