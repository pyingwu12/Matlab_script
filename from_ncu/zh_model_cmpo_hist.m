
clear

hr=0;   minu='00';   expri='largens';  mem=[92 143 183];
%---DA or forecast time---
if mem==0
%infilenam='wrfout';    type='sing';
%infilenam='output/fcstmean';  type=infilenam(8:11);  %!!!!%---experimental setting---
else
infilenam='wrfout';  dirnam='pert';    type='wrfo';
%infilenam='anal';    dirnam='cycle';  type=infilenam;
end
%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];   % path of the figure output
%indir=['/SAS009/pwin/expri_cctmorakot/',expri];
%outdir=['/SAS011/pwin/201work/plot_cal/morakot_shao/',expri,'/'];   % path of the figure output

%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_zh2.mat';  cmap=colormap_zh2;
%------
varinam='Zh comp.';    filenam=[expri,'_zh-vim-hist_']; 
plon=[118.3 122.85];  plat=[21.2 25.8];
range=0:5:55;

for mi=mem
for ti=hr;
%---set filename---
   s_hr=num2str(ti,'%2.2d');
   if mi==0
   %infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   else       
   nen=num2str(mi,'%.3d');
   infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   end
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');    qr  =double(netcdf.getVar(ncid,varid));  qr(qr<0)=0;
   varid  =netcdf.inqVarID(ncid,'QCLOUD');   qc  =double(netcdf.getVar(ncid,varid));  qc(qc<0)=0;
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));  qv(qv<0)=0;
   varid  =netcdf.inqVarID(ncid,'QICE');     qi  =double(netcdf.getVar(ncid,varid));  qi(qi<0)=0;
   varid  =netcdf.inqVarID(ncid,'QSNOW');    qs  =double(netcdf.getVar(ncid,varid));  qs(qs<0)=0;
   varid  =netcdf.inqVarID(ncid,'QGRAUP');   qg  =double(netcdf.getVar(ncid,varid));  qg(qg<0)=0;
   varid  =netcdf.inqVarID(ncid,'P');        p   =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');       pb  =double(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =double(netcdf.getVar(ncid,varid)); 
   varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =double(netcdf.getVar(ncid,varid)); 
   netcdf.close(ncid)   
%-------- 
   [nx,ny,nz]=size(qv);  zh=zeros(nx,ny,nz);
   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
%%---Lin scheme---
%   fin=find(temp < 273.15);
%   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+9.80e8*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);
%   fin=find(temp >= 273.15);
%   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+4.26e11*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);
%   %zh(zh<0)=0;
%   %
%---Gaddard scheme---
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.12e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
%---withou solid partical---   
%    zh=43.1+17.5*log10(den.*qr.*1.e3);
%    zh(zh<0)=0;
%---calculate vertical maximun--- 
   zh_max=max(zh,[],3); 
   zh_max2=zh_max(zh_max>=-5);
%--histogram   
   hi=cal_histc(zh_max2,range);  hi=hi./length(zh_max2).*100;
   
%---plot
   len=length(range)+1;
   
   figure('position',[100 500 800 500]) 
   hb=bar(1:len,hi);    colormap([0.5 0.87 0.96]);
   %
   set(gca,'fontsize',13,'XLim',[0 len+1],'XTick',0.5:len+0.5,'XTickLabel',[-inf,range,inf])
   set(gca,'YLim',[0 15])
   xlabel('dBZ','fontsize',14);   ylabel('number(%)','fontsize',14);
%---
   tit=[expri,'  ',varinam,'  ',s_hr,'z  (',type,', mem',num2str(mi),')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',type,'_m',num2str(mi)];
   %print('-dpng',outfile,'-r400') 
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);    
end
end