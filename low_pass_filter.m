  function filt=low_pass_filter(vari,fL,dx,dy)
  % vari: input variable for filter (2-D)
  % fL: wave length (km) to filter
  % dx, dy: grid spacing of x- and y-direction (km)
  
  if length(size(vari))~=2;   error('input data must be 2-D'); end
  if isempty(find(isnan(vari), 1))~=1; error('input data cannot have NaN'); end 

%---Low pass filter---
   [nx, ny]=size(vari);
   var_fft=fft2(vari);   var_fft=fftshift(var_fft);  %Discrete Fourier transform
   filnum=((dx*nx/fL)+(dy*ny/fL))*0.5; %decide the wave number
   %
   filter=ones(nx,ny);
   for i = 1:nx
     for j =1:ny
        dist = ((i-(nx/2))^2 + (j-(ny/2))^2)^.5;
        if dist > filnum
          filter(i,j) = 0;
        end
     end
   end
   var_fil=filter.*var_fft;   %execute filter
   var_fil = ifftshift(var_fil);
   var_fil = ifft2(var_fil);  %Inverse discrete Fourier transform
   filt = real(var_fil);

