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
function channels = channel_capacity(snr)
N = length(snr);
channels=channel.empty(N,0);
for i=1:N
    channels(i)= channel;
    channels(i).snr=10*log10(snr(i));
    channels(i).nbits=log2(1+snr(i));
    channels(i).nbits_rounded=round(channels(i).nbits);
    channels(i).find_diff();
    %channels(i).diff=channels(i).nbits-channels(i).nbits_rounded;
end
end
