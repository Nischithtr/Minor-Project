classdef channel < handle
    properties
        nbits;
        power;
        nbits_rounded;
        diff;
        snr;
    end
    methods
        function find_diff(obj)
            obj.diff=obj.nbits-obj.nbits_rounded;
        end
        function print(obj)
            disp("snr="+obj.snr);
            disp("nbits="+obj.nbits);
            disp("nbits_rounded="+obj.nbits_rounded);
            disp("power="+obj.power);
            disp("diff="+obj.diff);
        end

    end
end