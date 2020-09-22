function optimized_channels=adaptive_fine_gains(snr, b_target)
snr_abs = 10.^(snr./10);
unoptimized_channels = channel_capacity(snr_abs);
b_total=0;
for i=1:length(unoptimized_channels)
    b_total=b_total+unoptimized_channels(i).nbits_rounded;
end
if(b_total==0)
    optimized_channels=[];
    return;
end
while(b_total>b_target)
[~, ind] = sort([unoptimized_channels.diff],'ascend');
unoptimized_channels = unoptimized_channels(ind);
unoptimized_channels(1).nbits_rounded=unoptimized_channels(1).nbits_rounded-1;
unoptimized_channels(1).find_diff();
b_total=b_total-1;
end
while(b_total<b_target)
[~, ind] = sort([unoptimized_channels.diff],'descend');
unoptimized_channels = unoptimized_channels(ind);
unoptimized_channels(1).nbits_rounded=unoptimized_channels(1).nbits_rounded+1;
unoptimized_channels(1).find_diff();
b_total=b_total+1;
end
optimized_channels=unoptimized_channels;
for i=1:length(optimized_channels)
    optimized_channels(i).power=10*log10((2.^optimized_channels(i).nbits_rounded)-1);
end
disp("It's Alive!! It's Alive");
for i=1:length(optimized_channels)
    optimized_channels(i).print();
end
end

