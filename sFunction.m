function y = sFunction(x)
	 B = 0.3500;
	 T =  1.0000e-03;
	 Xoffset = 8.3500;
	 y = 0.95./(1+T*exp(-B.*(x-Xoffset))).^(1/T);
end

