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
symbols_sent_pilot1_t1 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);
symbols_sent_pilot2_t1 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

symbols_sent_pilot = [symbols_sent_pilot1_t1 symbols_sent_pilot2_t1];

rayleigh_channel = sqrt(1/2) .* (randn(1,4) + 1i*randn(1,4));
% h11 is first column
% h12 is second column
% h21 is third column
% h22 is fourth column
h = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel;
for ii = 1:Nsc
    h_freq{ii} = reshape(h(ii,:),2,2);
end

noise_power_db = -80; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot_r1_t1 = symbols_sent_pilot1_t1 .* h(:,1) + symbols_sent_pilot2_t1 .* h(:,3);
symbols_received_pilot_r2_t1 = symbols_sent_pilot1_t1 .* h(:,2) + symbols_sent_pilot2_t1 .* h(:,4);

symbols_sent_pilot1_t2 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);
symbols_sent_pilot2_t2 = - qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

symbols_received_pilot_r1_t2 = symbols_sent_pilot1_t2 .* h(:,1) + symbols_sent_pilot2_t2 .* h(:,3);
symbols_received_pilot_r2_t2 = symbols_sent_pilot1_t2 .* h(:,2) + symbols_sent_pilot2_t2 .* h(:,4);

estimated_h(:,1) = ((symbols_received_pilot_r1_t1 + symbols_received_pilot_r1_t2) ./ symbols_sent_pilot1_t1) ./ 2;
estimated_h(:,2) = ((symbols_received_pilot_r2_t1 + symbols_received_pilot_r2_t2) ./ symbols_sent_pilot1_t1) ./ 2;
estimated_h(:,3) = ((symbols_received_pilot_r1_t1 - symbols_received_pilot_r1_t2) ./ symbols_sent_pilot2_t1) ./ 2;
estimated_h(:,4) = ((symbols_received_pilot_r2_t1 - symbols_received_pilot_r2_t2) ./ symbols_sent_pilot2_t1) ./ 2;

for ii = 1:Nsc
    estimated_h_freq{ii} = reshape(estimated_h(ii,:),2,2);
end

g_array = zeros(1,Nsc);
bit_stream_rcvd = [];

g_array1 = ones(1,256) ;
g_array2 = ones(1,256) ;
bn1 = 20 .* ones(1,256); % Get only the number of rounded bits in the channel
bn2 = 20.* ones(1,256); % Get only the number of rounded bits in the channel
t1 = ones(1,256);
t2 = ones(1,256);

ii = 1;
h_factor_receiver = ones(1,256);
no_of_times = 0;
while (ii <= n_bits)
    data_one_pass_t1 = data(ii : min(ii + sum(bn1) - 1 , n_bits)) ;
    ii = ii + sum(bn1);
    [QAM_symbols(:,1),b_n_updated_1] = qam_mod(data_one_pass_t1,bn1,t1,g_array1); % QAM symbols
    data_one_pass_t2 = data(ii : min(ii + sum(bn2) - 1 , n_bits)) ;
    ii = ii + sum(bn2);
    [QAM_symbols(:,2),b_n_updated_2] = qam_mod(data_one_pass_t2,bn2,t2,g_array2); % QAM symbols
    
    QAM_symbols_1 = QAM_symbols.';
    
    for jj = 1:Nsc
        inv_test = inv(estimated_h_freq{jj});
        sent_symbols(:,jj) = inv(estimated_h_freq{jj}) * QAM_symbols_1(:,jj);
        received_symbols(:,jj) = h_freq{jj} * sent_symbols(:,jj) + noise(jj); 
    end
    
    received_symbols_1 = received_symbols.';
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols_1(:,1),b_n_updated_1',g_array1,h_factor_receiver)]; % Perform demod on the receiver end
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols_1(:,2),b_n_updated_2',g_array2,h_factor_receiver)]; % Perform demod on the receiver end
    no_of_times = no_of_times + 1;
end

err = sum(bit_stream_rcvd ~= data) ./ n_bits
fprintf(" Time taken = %d t1 \n" , no_of_times);
clear

n_bits = 10^4;
data = randi([0,1],1,n_bits) ;

Nsc = 256;
d = 1000;
bandwidth = 4000;
[Pt,Pr] = LOS(Nsc,d);

data_pilot = creverb1(Nsc); % PRBS
bits2persymbol = 2 .* ones(1,256);
g_pilot = ones(1,256);
t_pilot = 1:256;
symbols_sent_pilot1_t1 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);
symbols_sent_pilot2_t1 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

symbols_sent_pilot = [symbols_sent_pilot1_t1 symbols_sent_pilot2_t1];

rayleigh_channel = sqrt(1/2) .* (randn(1,4) + 1i*randn(1,4));
% h11 is first column
% h12 is second column
% h21 is third column
% h22 is fourth column
h = sqrt(Pr) ./ sqrt(Pt) * rayleigh_channel;
for ii = 1:Nsc
    h_freq{ii} = reshape(h(ii,:),2,2);
end

noise_power_db = -80; % Noise power in dbM
noise_power_abs = 10 .^ (noise_power_db ./ 10); % Absolute noise power
noise = sqrt(noise_power_abs/2) .* ((randn(Nsc,1)) + 1i*randn(Nsc,1)); % Noise

symbols_received_pilot_r1_t1 = symbols_sent_pilot1_t1 .* h(:,1) + symbols_sent_pilot2_t1 .* h(:,3);
symbols_received_pilot_r2_t1 = symbols_sent_pilot1_t1 .* h(:,2) + symbols_sent_pilot2_t1 .* h(:,4);

symbols_sent_pilot1_t2 = qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);
symbols_sent_pilot2_t2 = - qam_mod(data_pilot , bits2persymbol,t_pilot,g_pilot);

symbols_received_pilot_r1_t2 = symbols_sent_pilot1_t2 .* h(:,1) + symbols_sent_pilot2_t2 .* h(:,3);
symbols_received_pilot_r2_t2 = symbols_sent_pilot1_t2 .* h(:,2) + symbols_sent_pilot2_t1 .* h(:,4);

estimated_h(:,1) = ((symbols_received_pilot_r1_t1 + symbols_received_pilot_r1_t2) ./ symbols_sent_pilot1_t1) ./ 2;
estimated_h(:,2) = ((symbols_received_pilot_r2_t1 + symbols_received_pilot_r2_t2) ./ symbols_sent_pilot2_t1) ./ 2;
estimated_h(:,3) = ((symbols_received_pilot_r1_t1 - symbols_received_pilot_r1_t2) ./ symbols_sent_pilot1_t1) ./ 2;
estimated_h(:,4) = ((symbols_received_pilot_r2_t1 - symbols_received_pilot_r2_t2) ./ symbols_sent_pilot2_t1) ./ 2;

for ii = 1:Nsc
    estimated_h_freq{ii} = reshape(estimated_h(ii,:),2,2);
end

g_array = zeros(1,Nsc);
bit_stream_rcvd = [];

g_array1 = ones(1,256) ;
g_array2 = ones(1,256) ;
bn1 = 20 .* ones(1,256); % Get only the number of rounded bits in the channel
bn2 = 20 .* ones(1,256); % Get only the number of rounded bits in the channel
t1 = ones(1,256);
t2 = ones(1,256);

ii = 1;
h_factor_receiver = ones(1,256);
no_of_times = 0;
while (ii <= n_bits)
    data_one_pass_t1 = data(ii : min(ii + sum(bn1) - 1 , n_bits)) ;
    ii = ii + sum(bn1);
    [QAM_symbols(:,1),b_n_updated_1] = qam_mod(data_one_pass_t1,bn1,t1,g_array1); % QAM symbols
    data_one_pass_t2 = data(ii : min(ii + sum(bn2) - 1 , n_bits)) ;
    ii = ii + sum(bn2);
    [QAM_symbols(:,2),b_n_updated_2] = qam_mod(data_one_pass_t2,bn2,t2,g_array2); % QAM symbols
    
    QAM_symbols = QAM_symbols.';
    
    for jj = 1:Nsc
        inv_test = inv(estimated_h_freq{jj});
        sent_symbols(:,jj) = inv(estimated_h_freq{jj}) * QAM_symbols(:,jj);
        received_symbols(:,jj) = h_freq{jj} * sent_symbols(:,jj) + noise; 
    end
    
    received_symbols = received_symbols.';
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,1),b_n_updated_1',g_array1,h_factor_receiver)]; % Perform demod on the receiver end
    bit_stream_rcvd = [bit_stream_rcvd qam_demod(received_symbols(:,2),b_n_updated_2',g_array2,h_factor_receiver)]; % Perform demod on the receiver end
    number_of_times = number_of_times + 1;
end

err = sum(bit_stream_rcvd ~= data) ./ n_bits
fprintf(" Time taken = %d t1 \n" , number_of_times);
