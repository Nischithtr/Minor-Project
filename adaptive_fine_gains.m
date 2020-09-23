function optimized_channels=adaptive_fine_gains(snr, b_target)
snr_abs = 10.^(snr./10); % From given snr array turn it into absolute snr array
unoptimized_channels = channel_capacity(snr_abs, b_target); %Find a rough optimization through the algorithm
b_total=sum([unoptimized_channels.nbits_rounded]); %Find total number of bits
if(b_total==0) %If total number of bits is 0, then bad channel
    optimized_channels=[];
    return;
end
disp("Maximum channel capacity after applying Shannon's Law at existing conditions is " + b_total);
while(b_total>b_target) %If b_total>b_target, remove one bit from channel with smallest delta and recalculate delta for that channel
[~, ind] = sort([unoptimized_channels.diff],'ascend');
unoptimized_channels = unoptimized_channels(ind);
unoptimized_channels(1).nbits_rounded=unoptimized_channels(1).nbits_rounded-1;
unoptimized_channels(1).find_diff();
b_total=b_total-1;
end
while(b_total<b_target) %If b_total<b_target, add one bit from channel with smallest delta and recalculate delta for that channel
[~, ind] = sort([unoptimized_channels.diff],'descend');
unoptimized_channels = unoptimized_channels(ind);
unoptimized_channels(1).nbits_rounded=unoptimized_channels(1).nbits_rounded+1;
unoptimized_channels(1).find_diff();
b_total=b_total+1;
end
optimized_channels=unoptimized_channels; %Now b_total=b_target so recalculate the snrs for the channel
for i=1:length(optimized_channels)
    optimized_channels(i).power=10*log10((2.^optimized_channels(i).nbits_rounded)-1);
end
[~,ind] = sort([optimized_channels.channel_id],'ascend'); % Sort back into initial order by sorting by channel id
optimized_channels=optimized_channels(ind); 
figure(1); %Plot the tone order and snr for the different channels.
ii = 1:1:length(optimized_channels);
tone_loading = [optimized_channels.nbits_rounded];
tiledlayout(3,1);
nexttile;
stem(ii,snr);
title("Original input SNR");
nexttile;
stem(ii,[optimized_channels.power]);
title("SNR distribution of the channels");
nexttile;
stem(ii, tone_loading);
title("Tone loading of different channels");
end
