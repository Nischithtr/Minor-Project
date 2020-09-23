%This function calculates the channel capacity using Shannon's Theorem.
%Here snr is the array containing signal to noise ratios of various
%channels. It is NOT in dBs. tcarriers is the total number of available
%carriers. 
%Capacity is the array which has the channel capacity of ith
%channel. 
%tcarriers is the total number of available carriers.
%ncarriers is the total number of useful carriers among these
%tcarriers. If the capacity of any carrier is 0, then it is taken as
%useless,
function channels = channel_capacity(snr, b_target)
N = length(snr); %Find number of channels
channels=channel.empty(N,0); %Create an empty channel array of Nx1
gamma=0; %Initialise gamma = 0 (dB)
for i=1:N %Initalise N channels and assign ids
    channels(i)=channel;
    channels(i).channel_id=i;
    channels(j).snr=10*log10(snr(j));
end
for i=1:10 % This step iteratively refines the gamma value. More the number of iterations, finer the value. But, in most examples, 10 is taken as sufficient number
    used_carriers=N; %Initially assume all carriers are useful
    for j=1:N
        channels(j).nbits=log2(1+((snr(j)/9+gamma))); %Find SNRs from SCL
        channels(j).nbits_rounded=round(channels(j).nbits); %Round it
        if(channels(j).nbits_rounded==0)
            used_carriers=used_carriers-1; %If nbits_rounded is 0, useless channel, discard
        end
        channels(j).find_diff(); %Find the delta
    end
b_total = sum([channels.nbits_rounded]); %Find total number of bits by summing individual channel capacity
if(b_total==0) % If total number of bits is 0, then channel is too noisy
    channels=[];
    return;
end
if(b_total==b_target) % If our target matches total, job is done leave. (Ideally this should not be the case)
    return;
end
gamma = gamma + 10*log10(2^((b_total-b_target)/used_carriers)); % Recalculate gamma for the next iteration
end
end
