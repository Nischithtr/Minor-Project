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
        function print(self)
            disp("snr="+self.snr);
            disp("nbits="+self.nbits);
            disp("nbits_rounded="+self.nbits_rounded);
            disp("power="+self.power);
            disp("diff="+self.diff);
        end

    end
end