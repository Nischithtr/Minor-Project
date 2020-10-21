%Parameters
N = 1000000; % Number of symbols
M = 4; % modulation order
sigma = 1;
P = 1;

%Transmit symbol generation
x = randi([0 M-1],N,1); % N random integers between 0 and M-1
xmod = qammod(x,M); % QAM symbols corresponding to x

%Alamouti scheme
xal = zeros(2,N); % Specifiying the dimension of xal 
xal(:,1:2:N) = reshape(xmod,2,N/2); % The odd columns hold [x1;x2 x3;x4 ...]
xal(:,2:2:end) = (kron(ones(1,N/2),[-1;1]).*flipud(reshape(conj(xmod),2,N/2))); % The even columns hold [-x1*;x1* -x4*;x3* ...]

%Rayleigh Channel
h = conj((Rayleigh_fading(100,N,150,3,0.00000001))') ;
h_mod = sum(sqrt(sum(abs(reshape(h,2,N/2)).^2,1))) / (N/2);
h_comp = kron(reshape(h,2,N/2),ones(1,2)); % repeating the same channel for two symbols    


%Adding channel effect
x_chan = conj(sum(h_comp .* xal,1)'); 

%Adding AWGN
SNR_abs = (h_mod^4 * P / (2*sigma^2));
SNR = 10 * log10 (SNR_abs)
y = awgn(x_chan,SNR);

% Making y receiver compatible
y(2:2:end,:) = conj(y(2:2:end,:));
yc = kron(reshape(y,2,N/2),ones(1,2));

% Making h receiver compatible
h_rec = zeros(2,N);
h_rec(1,:) = h;
h_rec(2,:) = reshape(kron(ones(1,N/2),[1 ;-1]) .* flipud(reshape(conj(h),2,N/2)),1,N);

% Findind r
mod_c = (sum((abs(h_rec)).^2,1));   
r = conj((sum(conj(h_rec) .* yc) ./ mod_c)');
% y is divided by ||c||^2 as opposed to prescribed ||c||.
% resultantly noise variance changes to (sigma / ||c||)^2 accounted in the SNR formula                                                 

s = qamdemod(r,M);
errper = sum(s ~= x) / (N*M) *100
BER = 3 / ((2*SNR_abs)^2) *100