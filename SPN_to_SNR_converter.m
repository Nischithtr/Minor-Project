snr=zeros(256,1);
for i=1:5
    snr(i)=-inf;
end
for i=6:32
    snr(i)=92;
end
for i=33:50
    snr(i)=82;
end
for i=51:70
    snr(i)=72;
end
for i=71:100
    snr(i)=62;
end
for i=101:150
    snr(i)=52;
end
for i=151:200
    snr(i)=42;
end
for i=201:220
    snr(i)=22;
end
for i=220:254
    snr(i)=7;
end
for i=255:length(snr)
    snr(i)=-inf;
end

%snr = snr(snr~=-inf);
