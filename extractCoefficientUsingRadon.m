function quantizeddata = extractCoefficientUsingRadon( im )
%extractCoefficientUsingRadon MATLAB implementation of Robust image hash 
%in Radon transform domain for authentication
% image as input and returns significant dft coeffecients
[~,~,dim]=size(im);
if dim>1
    im=rgb2gray(im);
end
tic
x=zeros(1,180);
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
first15coeff=y(1:15);                            % only first 15 coefficients
first15coeff=first15coeff/max(first15coeff);                           % normalization
levels=linspace(0,1,1023);
quantizeddata = discretize(first15coeff, levels);
% bin = dec2bin(quantizeddata, 10);
toc
end

