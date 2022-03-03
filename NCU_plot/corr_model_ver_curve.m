clear

outdir='/SAS011/pwin/201work/plot_cal/largens';    plev=[5];
hr=2;  minu='00';  px=137;  py=118;   v1nam='QVAPOR';  v2nam='V';
%
%exp={'largens';'largens';'e01';'e02'};  exptext='_all';
%infile={'wrfout';'wrfout';'fcst';'fcst'};  dir={'pert';'pert';'cycle';'cycle'}; 
%memsize=[256 40 256 40]; cexp=[0 0 1 ; 0 0 1; 1 0 0; 1 0 0];  lexp={'-';'--';'-';'--'};
 exp={'e01';'e02'};  exptext='_fcst02';
 infilenam={'fcst';'fcst'};  dir={'cycle';'cycle'}; 
 memsize=[256 40]; cexp=[0.99 0.1 0.3; 0.3 0.5 0.95];  lexp={'-';'-'};
%
nexp=size(exp,1);
%---
if strcmp(v1nam(1),'Q')==1;  s_v1=v1nam(1:2);  else  s_v1=v1nam; end
if strcmp(v2nam(1),'Q')==1;  s_v2=v2nam(1:2);  else  s_v2=v2nam; end
corrvari=[s_v1,'-',lower(s_v2)]; 
%
varinam=[corrvari,' vertical Corr.'];    filenam='corr-ver_'; 
g=9.81;
global dom year mon date indir 
global nz
   
%----
 s_hr=num2str(hr,'%.2d');
 for i=1:nexp
 corr{i}=corr_cal_mvp(hr,minu,exp{i},v1nam,v2nam,px,py,memsize(i),infilenam{i},dir{i});
 explegend{i}=[exp{i} infilenam{i}];
 end
 for mi=1:memsize(nexp);
   nen=num2str(mi,'%.3d'); 
   infile=[indir,'/',dir{nexp},nen,'/',infilenam{nexp},'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   ncid = netcdf.open(infile,'NC_NOWRITE');      
   varid  =netcdf.inqVarID(ncid,'PH');       ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]); 
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]); 
   netcdf.close(ncid);
   %
   if mi==1;   zg=zeros(nz,memsize(nexp));    end
   P0=phb+ph;   PH=squeeze(P0(:,:,1:nz) + P0(:,:,2:nz+1) ).*0.5;     
   zg(:,mi)=PH./g;
end   %member
 zgm=round(mean(zg,2)/10)/100;  
%
%---plot---
for li=plev;
   lev=li;
   figure('position',[500 500 600 500]) 
   for i=1:nexp
    plot(corr{i}(lev,:),1:nz,'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2); hold on
   end
   %legh=legend('256 w/o da','40 w/o da','256 w/ da','40 w/ da'); 
   %legh=legend('256 mem (fcst)','40 mem (fcst)'); 
   legh=legend(explegend);
   set(legh,'fontsize',13,'Location','Southeast','box','off')
   line([0 0],[0 45],'color','k'); 
   %
   set(gca,'XLim',[-1 1],'YTick',1:5:nz,'YTickLabel',zgm(1:5:nz),'fontsize',13,'LineWidth',1)
   xlabel('Correlaiton','fontsize',14);  ylabel('height(km)','fontsize',14);
   %
   mem=num2str(memsize); lev=num2str(lev);  px=num2str(px); py=num2str(py);
   tit=['Vertical Correlation  ',s_hr,minu,'z  ',corrvari,' (lev',lev,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',px,py,'_',corrvari,'_lev',lev,exptext];
   %print('-dpng',[outfile,'.pdf'],'-r400')  
   %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   %system(['convert -trim -density 200 ',outfile,'.pdf ',outfile,'.png']);
   %system(['rm ',[outfile,'.pdf']]);
end
