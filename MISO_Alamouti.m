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

bn = 20 .* ones(1,256);
t = 1:256;
g_array = ones(1,256);
QAM_symbols = [];
received_symbols =[];
bit_stream_rcvd = [];
b_n_updated_full = [];

ii = 1;
N = 0;
while (ii <= nbits)
    N = N + 1;
    data_one_pass = data(ii : min(ii + sum(bn) - 1 , nbits)); 
    ii = ii + sum(bn);
    [QAM_symbols_one_pass,b_n_updated] = qam_mod(data_one_pass,bn,t,g_array); % QAM symbols
    QAM_symbols = [QAM_symbols QAM_symbols_one_pass];
    b_n_updated_full = [b_n_updated_full b_n_updated];
end

ii = 1;
while (ii < N)
    x1 = QAM_symbols(:,ii);
    x2 = QAM_symbols(:,ii + 1);
    
    y1 = h(:,1) .* x1 + h(:,2) .* x2 + noise ;
    y2 = - h(:,1) .* conj(x2) + h(:,2) .* conj(x1) + noise;
    
    estimated_x1 = (conj(estimated_h(:,1)) .* y1 + estimated_h(:,2) .* conj(y2)) ./ (abs(estimated_h(:,1)) .^2 + abs(estimated_h(:,2)) .^2);
    estimated_x2 = (conj(estimated_h(:,2)) .* y1 - estimated_h(:,1) .* conj(y2)) ./ (abs(estimated_h(:,1)) .^2 + abs(estimated_h(:,2)) .^2);
    
    received_symbols = [received_symbols estimated_x1 estimated_x2];
    
    ii = ii + 2;
end

h_syntax_sake = ones(Nsc,N);

ii = 1;
for ii = 1:N
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,ii),(b_n_updated_full(:,ii))',g_array,h_syntax_sake)]; % Perform demod on the receiver end
end

err = sum(bit_stream_rcvd ~= data) ./ nbits
