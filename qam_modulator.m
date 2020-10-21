function [mod_seq] = qam_modulator(x,k)
   %Padding zeros in the end
   [N,~] = size(x);
   if mod(N,k) ~= 0
    x = [x ; zeros((k - mod(N,k)),1)]     
   end

   % Parameters
   M = 2^k;
   [N,~] = size(x);
   
   mod_seq = zeros(N/k,1);
   
   % Bits to symbol
   symbol_bin = reshape(x,k,N/k);
   
   % Weight matrix
   index = (1 : k/2 -1)' ;
   weight = [((2 .^ index) .* (1 + i)) (( 2 .^ index) .* (2 + i))] ; 
   
   % Conjugation and factor matrix
   conjugation = [0 ; 1 ; 1 ;0];
   no_conjugation = [1 ; 0 ; 0 ; 1];
   fac = [-1 ; 1 ; -1; 1];
   
   % 4QAM and 8QAM constellations
   qam4 = [-1 - i ; 1 - i ; -1 + i ; 1 + i];
   qam8 = [qam4 ; -3 - i ; 3 - i ; -3 + i ; 3 + i];
    
   % 1 bit per symbol
   if k == 1
       mod_seq = 2 .* x - 1;
   
   % k bits per symbol where k is even
   else 
    for column = 1 : N/k
     if mod(k,2) == 0
         mod_symbol = qam4(bi2de([symbol_bin(1,column) symbol_bin(2,column)],'left-msb') + 1);
     else
         mod_symbol = qam8(bi2de([symbol_bin(1,column) symbol_bin(2,column) symbol_bin(3,column)],'left-msb') + 1)  ;      
     end
     if k > 3
      temp_bin = reshape(symbol_bin(mod(k,2) + 3: end,column),2,(k - mod(k,2) -2)/2); 
      temp_dec = bi2de(temp_bin','left-msb') ;
      for prog = 1 : (k - mod(k,2) -2)/2
       mod_symbol = fac(temp_dec(prog) +1) .* (conjugation(temp_dec(prog) + 1) .* conj(mod_symbol + weight(prog,mod(k,2) + 1)) + no_conjugation(temp_dec(prog) + 1) .* (mod_symbol + weight(prog,mod(k,2) + 1))) ;
      end
     end
     mod_seq(column) = mod_symbol ;
    end
    
    % k bits per symbol when k is odd
   end
end