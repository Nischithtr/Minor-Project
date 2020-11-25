t=1:256; % Tone loading table not yet used.
snr = LOS(Nsc)
snr = snr' ;
%snr=SPN_to_SNR_converter(); % Get the SNR table
b=basic_fine_gains(snr); % Get the adaptive bit loading
g_array=[b.pdiff]' ;
b=[b.nbits_rounded]; % Get only the number of rounded bits in the channel
[~,Nsc] = size(b); % Number of sub-carriers
sum(b)
data = creverb1(Nsc); % PRBS
data = [data  randi([0,1],1,635)] ;
QAM_symbols = qam_mod(data,b,t,g_array); % QAM symbols

noise_power_db = -140 : 10 : 30; % Noise power in db
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power

noise = sqrt(noise_power_abs/2) .* (randn(size(QAM_symbols)) + 1i*randn(size(QAM_symbols))); % Noise

%rayleigh_channel = sqrt(1/2) .* (randn(size(QAM_symbols)) + 1i*randn(size(QAM_symbols))); % Rayleigh channel added

received_symbols =  QAM_symbols + noise; % QAM symbol + AWGN noise

data = data(1:sum(b)); % Get the BER

for ii = 1 : 18
    bit_stream_rcvd(ii,:) = qam_demod(received_symbols(:,ii),b,g_array); % Perform demod on the receiver end
    err(ii) = sum(bit_stream_rcvd(ii,:) ~= data) / sum(b);
end

% Plot of BER vs SNR
plot( - noise_power_db,err)
title("BER vs SNR ")
xlabel("SNR")
ylabel("BER")

