%This class contains the different properties and methods which are part of
%any channel. This helps us to model multi-tone system as an array of
%channels.

classdef channel < handle
    properties
        nbits;  %Number of bits assigned from Shannon's Capacity Law
        power;  %Final power that must be put into the channel
        nbits_rounded; %Number of integer bits that must be put into the channel
        diff; %nbits-nbits_rounded
        snr; %The snr that must be maintained in the channel for given QoS
        channel_id; %The index of the channel in the multi-tone array during initialisation
    end
    methods
        function find_diff(obj)
            obj.diff=obj.nbits-obj.nbits_rounded; % Calculate diff
        end 
        function print(obj)  % Helper function to print the object properties
            disp("snr="+obj.snr);
            disp("nbits="+obj.nbits);
            disp("nbits_rounded="+obj.nbits_rounded);
            disp("power="+obj.power);
            disp("diff="+obj.diff);
        end

    end
end