function quantizeddata = hash_func( im )
%hash_func MATLAB implementation of Robust image hash in Radon transform domain for authentication
% image as input and returns significant dft coeffecients
x=[];
for th=0:1:179
    p=radon(im,th);
    p=nonzeros(p);
    temp_1=mean(p);
    c_mom=mean((p-temp_1).^3);        % 3rd order central moment
    mom= mean(p.^3);                  % 3rd order  moment
    n=c_mom/mom;                      % invariant parameter
    x(th+1)=n;
end
y=abs(fft(x,180));                    % all DFT coefficients
z=[];
for i=1:15                            % first 15 DFT coefficients
    z(i)=y(i);
end
z=z/max(z);                            % normalization;
levels=linspace(0,1,1023);
quantizeddata = discretize(z, levels); % discretized to 1024 level
% bin = dec2bin(quantizeddata, 10);

end

