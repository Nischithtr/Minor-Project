function optimized_channels=basic_fine_gains(snr)
snr_abs = 10.^(snr./10); % From given snr array turn it into absolute snr array
N = length(snr); %Find number of channels
bi_max=20;
max_deviation=2;
channels=channel.empty(N,0); %Create an empty channel array of Nx1
for i=1:N %Initalise N channels and assign ids
    channels(i)=channel;
    channels(i).channel_id=i;
    channels(i).snr=snr(i);
    channels(i).nbits=log2(1+snr_abs(i));
    channels(i).nbits_rounded=round(channels(i).nbits);
    channels(i).find_diff();
    channels(i).pdiff=-3*(channels(i).diff);
   
end
power_deviation = sum([channels.pdiff]);
while(abs(power_deviation)>max_deviation)
    if(power_deviation>max_deviation)
        [~, ind] = sort([channels.pdiff],'descend');
        channels=channels(ind);
        k=1;
        while(channels(k).nbits_rounded==0)
        k=k+1;
        end
        channels(k).nbits_rounded=channels(k).nbits_rounded-1;
        channels(k).find_diff();
        channels(k).pdiff=-3*(channels(k).diff);
        power_deviation = -3*sum([channels.diff]);
    end
    if(power_deviation<-max_deviation) %If b_total<b_target, add one bit from channel with smallest delta and recalculate delta for that channel
        k=1;
        [~, ind] = sort([channels.pdiff],'ascend');
        channels = channels(ind);
        while(channels(k).nbits_rounded>=bi_max)
            k=k+1;
        end
        channels(k).nbits_rounded=channels(k).nbits_rounded+1;
        channels(k).find_diff();
        channels(k).pdiff=-3*(channels(k).diff);
        power_deviation = -3*sum([channels.diff]);
    end
end
optimized_channels=channels;
[~,ind] = sort([optimized_channels.channel_id],'ascend'); % Sort back into initial order by sorting by channel id
optimized_channels=optimized_channels(ind);
for i=1:length(optimized_channels)
    optimized_channels(i).power=10*log10((2.^optimized_channels(i).nbits_rounded)-1);
    optimized_channels(i).nbits_rounded = min(20,optimized_channels(i).nbits_rounded);
end

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
disp("The power deviation is "+power_deviation);
end


