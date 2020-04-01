

infile = "wrfout_d01_3";
qv = ncread(infile,'QVAPOR');
u = ncread(infile,'U');

x = double(ncread(infile,'XLONG',[1 1 1],[Inf Inf 1]));
y = double(ncread(infile,'XLAT',[1 1 1],[Inf Inf 1]));

t=15;

%figure
%plot(squeeze(u(20,20,:,t)))
%%
figure
for t=2
  contourf(u(:,:,3,t),20,'linestyle','none')
    pause(0.5);  
end
%%
