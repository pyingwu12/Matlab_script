function [u,v,w,th,qv,temp,slp,pressure,zg,mu]=getnc_vars(infile,n,xlon,ylat,eta);
%starggered in vertical
in1z=1:length(eta);
in2z=in1z+1;
%starggered in horizontal
in1=1:size(xlon,1);
in2=in1+1;
in1x=1:size(xlon,2);
in2x=in1x+1;
in1y=1:size(xlon,1);
in2y=in1y+1;
utmp=getnc(infile,'U',[n -1 -1 -1],[n -1 -1 -1]);
vtmp=getnc(infile,'V',[n -1 -1 -1],[n -1 -1 -1]);
wtmp=getnc(infile,'W',[n -1 -1 -1],[n -1 -1 -1]);

ph=getnc(infile,'PH',[n -1 -1 -1],[n -1 -1 -1]);
ps=getnc(infile,'PSFC',[n -1 -1],[n -1 -1]);
phb=getnc(infile,'PHB',[n -1 -1 -1],[n -1 -1 -1]);
qv=getnc(infile,'QVAPOR',[n -1 -1 -1],[n -1 -1 -1]);
th=getnc(infile,'T',[n -1 -1 -1],[n -1 -1 -1])+300.0;
mu=getnc(infile,'MU',[n -1 -1],[n -1 -1]);
mub=getnc(infile,'MUB',[n -1 -1],[n -1 -1]);
mu=mub+mu;

zgtmp=squeeze((ph+phb)/9.81);
zg=0.5*(zgtmp(in1z,:,:)+zgtmp(in2z,:,:));
u=0.5*(utmp(:,:,in1x)+utmp(:,:,in2x));
v=0.5*(vtmp(:,in1y,:)+vtmp(:,in2y,:));
w=0.5*(wtmp(in1z,:,:)+wtmp(in2z,:,:));
for z=1:length(eta)
    pressure(z,:,:)=5000.0+(ps-5000.0).*eta(z);
end
%temp=0;slp=0;
temp=wrf_tk(pressure,th,'K');
slp=calc_slp(pressure,zg,temp,qv);
return
