% compuate the sea-level pressure
function [slp]=getslp(ps,ph,phb,qv,th,eta);

if ( length(size(ph)) ~=3 || length(size(phb)) ~=3 || length(size(qv)) ~=3 || length(size(th)) ~=3)
   fprintf(1,'%s','chech the dimension of the input data\n')
   return
elseif (length(size(ps)) ~=2 )
   fprintf(1,'%s','chech the dimension of the input data\n')
   return
end
zgtmp=(ph+phb)/9.81;
% for staggered grid
if (size(ph,1)==size(th,1)+1)
   in1z=1:size(ph,1)-1;
   in2z=in1z+1;
   zg=0.5*(zgtmp(in1z,:,:)+zgtmp(in2z,:,:));
else
   zg=zgtmp;
end
clear zgtmp;
for z=1:length(eta)
    pressure(z,:,:)=5000.0+(ps-5000.0).*eta(z);
end
temp=wrf_tk(pressure,th,'K');
slp=calc_slp(pressure,zg,temp,qv);
return
