
clear
hr=2;   minu='00';   expri='largens';   infilenam='wrfout';  dirnam='pert';  
px=115;  py=90;  n=40;

outdir='/work/pwin/plot_cal/largens'; 

global dom year mon date indir nz
g=9.81;

%---
s_hr=num2str(hr,'%2.2d'); 
%---
Rbig  =a_cal_corr_model_ver(hr,minu,expri,infilenam,dirnam,px,py,256);
Rsmall=a_cal_corr_model_ver(hr,minu,expri,infilenam,dirnam,px,py,n);

%---read model high at(px,py)
for mi=1:n;
   nen=num2str(mi,'%.3d'); 
   infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   ncid = netcdf.open(infile,'NC_NOWRITE');      
   varid  =netcdf.inqVarID(ncid,'PH');       ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]); 
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]); 
   netcdf.close(ncid);
   %
   if mi==1;   zg=zeros(nz,n);       end
   P0=phb+ph;   PH=squeeze(P0(:,:,1:nz) + P0(:,:,2:nz+1) ).*0.5;     
   zg(:,mi)=PH./g;
end   %member
%
zgm=mean(zg,2);
%---calculate distant between each level---
dis=zeros(nz,nz);
for i=1:nz
  for j=1:nz
    dis(i,j)=abs(zgm(i)-zgm(j));
  end          
end
nvar=size(Rsmall,1)/nz;
disall=repmat(dis,nvar,nvar)./1000;
%---calculate RLd

L=0.5:0.5:40; ln=length(L);
norm2=zeros(ln,1);  normf=zeros(ln,1); 
for i=1:ln
  Ld=exp(-disall.^2/(L(i))^2);
  RLd=Rsmall.*Ld;  
  norm2(i)=norm(RLd-Rbig);
  normf(i)=norm(RLd-Rbig,'fro');
end    

%------
figure('position',[500 500 600 500]) 
plot(L,norm2,'LineWidth',2);  hold on; 
plot(L,normf./2,'LineWidth',2,'color','r')
legend('norm2','normf','location','best')
set(gca,'xdir','reverse','XLim',[-3 42],'YLim',[fix(min(norm2)/10)*10 ceil(max(norm2)/10)*10],'fontsize',16,'LineWidth',0.8)

norm2_40=norm(Rbig-Rsmall);
line([-3 42],[norm2_40 norm2_40],'color','k','LineStyle','--')
text(0,20-0.5,'40','color','r','fontsize',16);  text(0,30-0.5,'60','color','r','fontsize',16); 
px=num2str(px); py=num2str(py);
text(10,12,['px=',px,', py=',py],'color','k','fontsize',14); 

xlabel('L(localization radius)','fontsize',14);   ylabel('||R-R*L(d)||','fontsize',14)

mem=num2str(n);
tit=['L-R*L(d) ',s_hr,minu,'z  (',infilenam,', n=',mem,')']; 
title(tit,'fontsize',15)
outfile=[outdir,'/L_RLd_',s_hr,minu,'_',px,py,'_',infilenam(1:4),'_m',mem,'.png'];
print('-dpng',outfile,'-r400')  

