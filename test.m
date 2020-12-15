t=1:256; % Tone loading table not yet used.
Nsc = 256;
d = 1000;
bandwidth = 4000;
[Pt,Pr] = LOS(Nsc,d);
data = creverb1(Nsc); % PRBS
bits2persymbol = 2 .* ones(256,1);
g = ones(256,1);
symbols_sent = qam_mod(data , bits2persymbol,t,g);

symbols_received = symbols_sent .* Pr / Pt;

estimated_Pr = (abs(symbols_received) .^ 2) ./ (abs(symbols_sent) .^ 2) * Pt;
snr = 10 * log10(estimated_Pr) + 130 - 10 * log10(bandwidth) ;

snr = snr' ;
%snr=SPN_to_SNR_converter(); % Get the SNR table
b=basic_fine_gains(snr); % Get the adaptive bit loading
g_array=[b.pdiff]' ;
b=[b.nbits_rounded]; % Get only the number of rounded bits in the channel
[~,Nsc] = size(b); % Number of sub-carriers
data = randi([0,1],1,sum(b)) ;
QAM_symbols = qam_mod(data,b,t,g_array); % QAM symbols

noise_power_db = -140 : 10 : 30; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power

noise = sqrt(noise_power_abs/2) .* (randn(size(QAM_symbols)) + 1i*randn(size(QAM_symbols))); % Noise

%rayleigh_channel = sqrt(1/2) .* (randn(size(QAM_symbols)) + 1i*randn(size(QAM_symbols))); % Rayleigh channel added

received_symbols =  QAM_symbols + noise; % QAM symbol + AWGN noise

bit_stream_rcvd = zeros(18,sum(b));

for ii = 1 : 18
    bit_stream_rcvd(ii,:) = qam_demod(received_symbols(:,ii),b,g_array); % Perform demod on the receiver end
    err(ii) = sum(bit_stream_rcvd(ii,:) ~= data) / sum(b);
end

% Plot of BER vs SNR
plot( - noise_power_db,err)
title("BER vs SNR ")
xlabel("SNR")
ylabel("BER")

