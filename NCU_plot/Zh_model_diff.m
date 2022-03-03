%-------------------------------------------------------
% ZH difference(exp1-exp2) between expri1 to expri2  (DA cycle & forecasting time)
%-------------------------------------------------------

clear

hr=2;  expri1='e01';  expri2='e02'; 
%---DA or forecast time---
infilenam='wrfout';  minu='00';            type='sing';
%infilenam='output/fcstmean';  minu='00';  type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/'; outdir=['/work/pwin/plot_cal/largens/',expri1];   % path of the figure output
L=[-10 -7 -4 -3 -2 -1  1 2 3 4 5 7]*5;
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br4.mat';  %cmap=flipud(colormap_br4); cmap(1:6,:)=fliplr(flipud(cmap(8:13,:)));
cmap=colormap_br4;
%------
varinam='Zh composite';  filenam=[expri1,'_Zhc-diff_-',expri2,''];
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.3 121.8];  plat=[21 24.3];
g=9.81;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');    qr  =double(netcdf.getVar(ncid,varid));  qr(qr<0)=0;
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));  qv(qv<0)=0;
   varid  =netcdf.inqVarID(ncid,'QSNOW');    qs  =double(netcdf.getVar(ncid,varid));  qs(qs<0)=0;
   varid  =netcdf.inqVarID(ncid,'QGRAUP');   qg  =double(netcdf.getVar(ncid,varid));  qg(qg<0)=0;
   varid  =netcdf.inqVarID(ncid,'P');        p   =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');       pb  =double(netcdf.getVar(ncid,varid)); 
   varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
   netcdf.close(ncid)
   [nx,ny,nz]=size(qv);  zh=zeros(nx,ny,nz);
   %---Gaddard Zh composite---
   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.12e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   zh_max1=max(zh,[],3);  
   
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'QRAIN');    qr  =double(netcdf.getVar(ncid,varid));  qr(qr<0)=0;
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));  qv(qv<0)=0;
   varid  =netcdf.inqVarID(ncid,'QSNOW');    qs  =double(netcdf.getVar(ncid,varid));  qs(qs<0)=0;
   varid  =netcdf.inqVarID(ncid,'QGRAUP');   qg  =double(netcdf.getVar(ncid,varid));  qg(qg<0)=0;
   varid  =netcdf.inqVarID(ncid,'P');        p   =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');       pb  =double(netcdf.getVar(ncid,varid)); 
   varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
   netcdf.close(ncid)
  %---Gaddard Zh composite---
   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.12e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   zh_max2=max(zh,[],3); 
%------------------    
   diff=zh_max1-zh_max2;    
  
%--plot----
   plotvar=diff;   
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',120.8506,'parallels',[13.65 33.65],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
   cm=colormap(cmap);  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   %m_gshhs_h('color','k','LineWidth',0.8);    
    %
   tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type];
%    print('-dpng',outfile,'-r400')       
%     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%     system(['rm ',[outfile,'.pdf']]); 
end    
