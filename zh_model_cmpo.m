%close all
clear
%---setting
expri='test18';
%year='2007'; mon='06'; date=1;
year='2018'; mon='09'; date=19;
sth=1; acch=12; minu='00';
titnam='Accumulated Rainfall';   fignam=[expri,'_accum_'];

%---experimental setting---
indir=['/SAS009/pwin/expri_largens/',expri]; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];   % path of the figure output
L=[0 5 10 15 20 25 30 35 40 45 50 55 60 65];

%---set
addpath('m_map/')
addpath('/work/pwin/data/colorbar/');     
load('colormap_zh2.mat');  cmap=colormap_zh2;

 plon=[118.9 121.8];   plat=[21 24.3];


for ti=hr;
%---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
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
   varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
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
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.21e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
%---withou solid partical---   
%    zh=43.1+17.5*log10(den.*qr.*1.e3);
%    zh(zh<0)=0;
%---calculate vertical maximun---      
   zh_max=max(zh,[],3);    
%--------------------------------   
   if conid~=0;
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'U');        u.stag =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'V');        v.stag =netcdf.getVar(ncid,varid);
     dx =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX')); 
     dy =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY'));
      netcdf.close(ncid)
     u.p=(u.stag(2:end,:,:)-u.stag(1:end-1,:,:))./dx;
     v.p=(v.stag(:,2:end,:)-v.stag(:,1:end-1,:))./dy; 
     conv=-(u.p+v.p);
   end
   %
%---plot---
   plotvar=zh_max;   %plotvar(plotvar<=0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
   figure('position',[600 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none'); 
   %
   if conid~=0; 
       hold on; m_contour(x,y,conv(:,:,lev)*1e3,[0.5 0.5],'color',[0.1 0.02 0.2],'LineWidth',1.2); 
   end
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);    
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
%---
   if conid~=0;   tit=[expri,'  ',varinam,'  ',s_hr,'z  (',type,' lev',num2str(lev),')']; 
                  outfile=[outdir,filenam,s_hr,'_',type,'_lev',num2str(lev)];
   else tit=[expri,'  ',varinam,'  ',s_hr,'z  (',type,')'];  outfile=[outdir,filenam,s_hr,'_',type];
   end
   title(tit,'fontsize',15)
   %print('-dpng',outfile,'-r400') 
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);    
end
