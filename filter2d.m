  function filt=filter2d(vari,fLb,fLu,dx,dy)
  % vari: input variable for filter (2-D)
  % fLb: wave length (km) to filter (bottom)
  % fL: wave length (km) to filter (upper)
  % dx, dy: grid spacing of x- and y-direction (km)
  
%   vari= testvari(1+idifx:end-idifx,1+idifx:end-idifx);
%   fLb=0.0001;  fLu=1000;
%   dx=5; dy=5;
  
%
  vari=squeeze(vari);
  if length(size(vari))~=2;   error('input data must be 2-D'); end
  if isempty(find(isnan(vari), 1))~=1; error('input data cannot have NaN'); end 

%---Low pass filter---
   [nx, ny]=size(vari);
   var_fft=fft2(vari);   var_fft=fftshift(var_fft);  %Discrete Fourier transform
   filnumb=((dx*nx/fLb)+(dy*ny/fLb))*0.5; %decide the wave number (small wave length, large wave number)
   filnumu=((dx*nx/fLu)+(dy*ny/fLu))*0.5; %decide the wave number
   %
   filtermask=ones(nx,ny);
   for i = 1:nx
     for j =1:ny
        dist = ((i-(nx/2))^2 + (j-(ny/2))^2)^.5;
        if dist <= filnumb && dist > filnumu
          filtermask(i,j) = filtermask(i,j);
        else
          filtermask(i,j) = 0;  
        end
     end
   end
   var_fil=filtermask.*var_fft;   %execute filter
   var_fil = ifftshift(var_fil);
   var_fil = ifft2(var_fil);  %Inverse discrete Fourier transform
   filt = real(var_fil);

% figure; contour(filt')