%-----------------------------------------------
% Calculate the vertical correlation between u, v, w, (ws), t, qv, (qr) at the point: (px,py)
% Plot the matrix of the correlation,
% something like this:     ---------
%                       u | \       |
%                       v |   \     |
%                       w |     \   |
%                       t |       \ |
%                       q  ---------
%                          u v w t q....
%------------------------------------------------
clear

hr=0;   minu='00';     ticklabel={'u';'v';'w';'ws';'T';'qv';'qr'};
%ticklabel={'U';'V';'W';'T';'Qv'};
%expri='e01';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
memsize=256; 
px=137;  py=118;   
%px=115;  py=90;
%px=161;  py=147;   %px=137;  py=111;
%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir='/SAS011/pwin/201work/plot_cal/largens'; 
%indir=['/work/pwin/data/sz_wrf2obs_',expri]; outdir='/SAS011/pwin/201work/plot_cal/IOP8'; 
%---
varinam='vertical Corr.';    filenam=[expri,'_corr-verall_']; 
px0=px-1; py0=py-1;
%---
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d'); 
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
      ncid = netcdf.open(infile,'NC_NOWRITE');      
      varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'U');       ustag =netcdf.getVar(ncid,varid,[px0 py0 0 0],[2 1 nz 1]);   
      varid  =netcdf.inqVarID(ncid,'V');       vstag =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 2 nz 1]);
      varid  =netcdf.inqVarID(ncid,'W');       wstag =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz+1 1]);  
      varid  =netcdf.inqVarID(ncid,'T');       t0    =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz 1]);
      varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv0   =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz 1]); 
      varid  =netcdf.inqVarID(ncid,'QRAIN');   qr0   =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz 1]);
      netcdf.close(ncid);
      %
      if mi==1  
       U=zeros(nz,memsize);   V=zeros(nz,memsize);   W=zeros(nz,memsize);   T=zeros(nz,memsize);
       QV=zeros(nz,memsize); QR=zeros(nz,memsize);
      end
      U(:,mi)=squeeze(ustag(1,:,:)     +ustag(2,:,:)   ).*0.5;
      V(:,mi)=squeeze(vstag(:,1,:)     +vstag(:,2,:)   ).*0.5;
      W(:,mi)=squeeze(wstag(:,:,1:nz)+wstag(:,:,2:nz+1)).*0.5;
      %  W(:,mi)=squeeze(wstag);
      T(:,mi)=squeeze(t0+300);
      QV(:,mi)=squeeze(qv0).*10^3;      
      QR(:,mi)=squeeze(qr0).*10^3;               
   end   %member
   WS=(U.^2+V.^2).^0.5;
   A=[U; V; W; WS; T; QV; QR]; 
   %A=[U; V; W; T; QV;]; 
%-----calculate correlation------------
   at=mean(A,2);   At=repmat(at,1,memsize);   Ae=A-At;
   %---variance---    
   % !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean here
   varae=sum(Ae.^2,2)./(memsize-1);     
   varaeall=(varae.^0.5)*(varae'.^0.5);
   cov=(Ae*Ae')./(memsize-1); %covariance   
   %---correlation--- 
   corr=cov./(varaeall);
   corr(single(varaeall)==0)=0;
   
   %R=single(corr);
   %cn=sqrt(40-3)/sqrt(256-3);
   %Rp=( (1+R).^cn -(1-R).^cn ) ./  ( (1+R).^cn  + (1-R).^cn );
   
%---plot---
   np=size(A,1);
   figure('position',[500 500 620 500]) 
   %
   %[c hp]=contourf(corr,50);   set(hp,'linestyle','none');  set(gca,'Ydir','reverse'); hold on  
   imagesc(corr); hold on
   hc=colorbar;   caxis([-1 1]); set(hc,'LineWidth',1)
   set(gca,'XTick',nz/2:nz:np,'XTickLabel',ticklabel,'YTick',nz/2:nz:np,'YTickLabel',ticklabel, ...
           'TickLength',[0 0],'fontsize',13,'LineWidth',1)
   %---plot the grid line---
   for i=1:np/nz-1
   line([nz*i+0.5 nz*i+0.5],[0 np],'color','k','LineWidth',0.8);   
   line([0 np],[nz*i+0.5 nz*i+0.5],'color','k','LineWidth',0.8)
   end
   %line([0 np],[190 190],'color','k','LineStyle','--');   
   %line([53 53],[0 np],'color','k','LineStyle','--');  
   %
   px=num2str(px); py=num2str(py);
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', mem',num2str(memsize),')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',px,py,'_',type,'_m',num2str(memsize)];
   print('-dpng',[outfile,'.png'],'-r400')     
   %---can not convert file when used the function <imagesc> to plot the figure (don't know why
   %set(gcf,'PaperPositionMode','auto'); print('-dpdf',[outfile,'.pdf']) 
   %system(['convert -trim -density 100 ',outfile,'.pdf ',outfile,'.png']);
   %system(['rm ',[outfile,'.pdf']]);
end
