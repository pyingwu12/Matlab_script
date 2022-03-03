
clear
hr=2;   minu='00';   expri='largens';   infilenam='wrfout';  dirnam='pert';  
%expri='e02';   infilenam='fcst';    dirnam='cycle';
px=137;  py=118;   n=40;  L=30;
%---
global dom year mon date indir nz
outdir='/work/pwin/plot_cal/largens'; 
ticklabel={'u';'v';'w';'ws';'t';'qv';'qr'};
g=9.81;
%---
for ti=hr
%------    
   s_hr=num2str(ti,'%2.2d');  
%------
   Rsmall=a_cal_corr_model_ver(ti,minu,expri,infilenam,dirnam,px,py,n);   
   %---read model high at(px,py)
   for mi=1:n;
      nen=num2str(mi,'%.3d'); 
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
      ncid = netcdf.open(infile,'NC_NOWRITE');      
      varid  =netcdf.inqVarID(ncid,'PH');       ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]); 
      varid  =netcdf.inqVarID(ncid,'PHB');       phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]); 
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
   %---apply localization
   Ld=exp(-disall.^2/L^2);
   RL=Rsmall.*Ld;
%------
   np=nvar*nz;
   figure('position',[500 500 600 500]) 
%
   imagesc(RL); hold on
   colorbar;   caxis([-1 1])  
   set(gca,'XTick',nz/2:nz:np,'XTickLabel',ticklabel,'YTick',nz/2:nz:np,'YTickLabel',ticklabel, ...
           'TickLength',[0 0],'fontsize',13,'LineWidth',0.8)
   %---plot the grid line---
   for i=1:np/nz-1
    line([nz*i+0.5 nz*i+0.5],[0 np],'color','k','LineWidth',0.8);   
    line([0 np],[nz*i+0.5 nz*i+0.5],'color','k','LineWidth',0.8)
   end
%
   px=num2str(px); py=num2str(py);  mem=num2str(n); L=num2str(L);
   tit=['L(d) localization  ',s_hr,minu,'z  (',infilenam,', mem',mem,', L=',L,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/RL_',s_hr,minu,'_',px,py,'_',infilenam(1:4),'_m',mem,'_L',L,'.png'];
   print('-dpng',outfile,'-r400')     
end