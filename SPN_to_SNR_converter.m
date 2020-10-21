function snr=SPN_to_SNR_converter()
    bandwidth=4000;
    snr=zeros(256,1);
    for i=1:5
        snr(i)=-inf;
    end
    for i=6:32
        snr(i)=92 - 10*log10(bandwidth);
    end
    for i=33:50
        snr(i)=82 - 10*log10(bandwidth);
    end
    for i=51:70
        snr(i)=72 - 10*log10(bandwidth);
    end
    for i=71:100
        snr(i)=62 - 10*log10(bandwidth);
    end
    for i=101:150
        snr(i)=52 - 10*log10(bandwidth);
    end
    for i=151:200
        snr(i)=42 - 10*log10(bandwidth);
    end
    for i=201:220
        snr(i)=22 - 10*log10(bandwidth);
    end
    for i=220:254
        snr(i)=7 - 10*log10(bandwidth);
    end
    for i=255:length(snr)
        snr(i)=-inf;
    end
end