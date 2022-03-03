%function [u,v,w,th,qv,temp,slp,pressure]=getnc_vars(infile,n,xlon,ylat,eta);
%starggered in vertical
%infile='/mnt/ddal01/scyang/WRFEXPS/exp07/e01/da_out/wrfanal_d01_2006-09-14_06:00:00';
infile=file_t;
infile='/mnt/ddal01/scyang/WRFEXPS/exp07/e04/da_out/wrfinput_d01_148180_0_5'
in1z=1:length(eta);
in2z=in1z+1;
%starggered in horizontal
in1=1:size(xlon,1);
in2=in1+1;
etag  = getnc(infile,'ZNW');
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

zgtmp=squeeze((ph+phb)/9.81);
zg=0.5*(zgtmp(in1z,:,:)+zgtmp(in2z,:,:));
u=0.5*(utmp(:,:,in1)+utmp(:,:,in2));
v=0.5*(vtmp(:,in1,:)+vtmp(:,in2,:));
w=0.5*(wtmp(in1z,:,:)+wtmp(in2z,:,:));
for z=1:length(eta)
    pressure(z,:,:)=5000.0+(ps-5000.0).*eta(z);
end
cp=287*7/2;
cv=cp-287.;
alphad=1.e-5*287.0*(th+300.00).*(1+1.61*qv).*(pressure*1.e-5).^(-cv/cp);
for z=1:length(etag)
    pres(z,:,:)=5000.0+(ps-5000.0).*etag(z);
end
phs=ph+phb;
temp=wrf_tk(pressure,th,'K');
slp=calc_slp(pressure,zg,temp,qv);
for z=1:size(eta)
dpdph=(pres(z+1,:,:)-pres(z,:,:))./(phs(z+1,:,:)-phs(z,:,:));
RTPinv=(287*temp(z,:,:)./pressure(z,:,:));
dphdeta=(phs(z+1,:,:)-phs(z,:,:))/(etag(2)-etag(1));
b(z,:,:)=squeeze(dphdeta)./(mu+mub).*squeeze(alphad(z,:,:));
end
return
