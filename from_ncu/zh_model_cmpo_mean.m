%
clear all
close all
%
hr=00;   minu='00';   expri='largens';   memsize=256;  plotid=2;  % 1)mean 2)PM 3)PMmod

%---DA or forecast time---
infilenam='wrfout';   dirnam='pert';

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];   % path of the figure output
L=[0 5 10 15 20 25 30 35 40 45 50 55 60 65];

%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_zh2.mat';  cmap=colormap_zh2;
%------
vari='Zh';    filenam=[expri,'_zh-model_'];
%plon=[118.3 121.8];  plat=[21 24.3];
plon=[117.5 122.5]; plat=[20.5 25.65];
%plon=[117.85 121.8]; plat=[20.5 24.65];
type={'mean';'PM';'PMmod'};

for ti=hr;
  s_hr=num2str(ti,'%2.2d');  % start time string
%{
  for mi=1:memsize
%---set filename---
     nen=num2str(mi,'%.3d');     %nen=num2str(mi,'%.2d');  
     infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00']; 
%------read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'QRAIN');    qr  =double(netcdf.getVar(ncid,varid));  qr(qr<0)=0;
     varid  =netcdf.inqVarID(ncid,'QCLOUD');   qc  =double(netcdf.getVar(ncid,varid));  qc(qc<0)=0;
     varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));  qv(qv<0)=0;
     varid  =netcdf.inqVarID(ncid,'QICE');     qi  =double(netcdf.getVar(ncid,varid));  qi(qi<0)=0;
     varid  =netcdf.inqVarID(ncid,'QSNOW');    qs  =double(netcdf.getVar(ncid,varid));  qs(qs<0)=0;
     varid  =netcdf.inqVarID(ncid,'QGRAUP');   qg  =double(netcdf.getVar(ncid,varid));  qg(qg<0)=0;
     varid  =netcdf.inqVarID(ncid,'P');        p   =double(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'PB');       pb  =double(netcdf.getVar(ncid,varid)); 
     varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
     if mi==1
     varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
     [nx,ny,nz]=size(qv);
     end
     netcdf.close(ncid)
% -------- 
     zh=zeros(nx,ny,nz);
     temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
     den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
     fin=find(temp < 273.15);
     zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
     fin=find(temp >= 273.15);
     zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.21e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);    
     
     clear zh_max
     zh_max=max(zh,[],3);  
     zh_max(zh_max<0)=0;
     zh_maxi{mi}=zh_max;
  end %member

%  infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_mean'];
%  ncid = netcdf.open(infile,'NC_NOWRITE');
%  varid  =netcdf.inqVarID(ncid,'W');    w =netcdf.getVar(ncid,varid); 
 
%---caculate mean---
  [meacci PM PMmod]=calPM(zh_maxi);   
%}
%---load---
load('zhmean_256.mat')
PM=zh_mean;
%---save---
%zh_mean=PM;
%save('zhmean_40_LE0614.mat','zh_mean','x','y')
%
%---plot---
%%
  for pi=plotid   % 1:mean, 2:PM, 3:PMmod
    switch (pi); case 1; plotvar=meacci;  case 2; plotvar=PM; case 3; plotvar=PMmod;  end    
    plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
    figure('position',[200 200 900 750])
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none'); 
    %
    %hold on
    %m_contour(x,y,w,[0.1 0.5])
    %
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45,'fontsize',16);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);
    cm=colormap(cmap);    
    hc=Recolor_contourf(hp,cm,L,'h');  set(hc,'fontsize',17,'LineWidth',1)
%    set(hc,'position',[0.8 0.12 0.0275 0.8])
%    title(hc,'dBZ','position',[0.5 55],'fontsize',17)
     set(hc,'position',[0.205 0.038 0.62 0.022])
     title(hc,'dBZ','position',[-2.5 -0.3],'fontsize',17)
%---zh_max
    %tit=[expri,'  ',vari,'  ',s_hr,'z  (',type{pi},' mem=',num2str(memsize),')'];   
    tit='Composite reflectivity (PM ensemble mean)';
    title(tit,'fontsize',18,'Position',[-0.016 0.0455],'FontWeight','bold')
    outfile=[outdir,filenam,s_hr,'_',type{pi},num2str(memsize)];
%   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%   system(['convert -trim -density 600 ',outfile,'.pdf ',outfile,'.png']);
%   system(['rm ',[outfile,'.pdf']]);  
  end %plotid
%}
end %time

