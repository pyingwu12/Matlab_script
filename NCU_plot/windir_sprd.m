%function 
%-------------------------------------------------------
% wind direction spread of experi (DA cycle & forecasting time)
%-------------------------------------------------------
%
clear all
close all

hr=0;   minu='00';   expri='largens';   isoid=0;   % 0:model level. ~=0:constant-height
memsize=256;
%
if isoid==0; lev=10; else hgt_w=3000; end  % level or height for plot
%---DA or forecast time---
%infilenam='anal';    type='anal';  dirnam='cycle';
infilenam='wrfout';  type='wrfout';  dirnam='pert';

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';   % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[10 14 18 22 26 30 34 38 42];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_sprd.mat';  cmap=colormap_sprd([1 3 4 6 7 9 11 13 14 15],:);
%----
filenam=[expri,'_wdir-sprd_'];   varinam='wind direction spread';
plon=[118.4 121.8]; plat=[20.65 24.35];
int=5; %inteval for plot wind barb

%----
for ti=hr
%---set time and filename---    
    s_hr=num2str(ti,'%2.2d'); 
    cmean=0; smean=0;  umean=0; vmean=0;
    for mi=1:memsize
%---set filename---
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      if mi==1
        varid  =netcdf.inqDimID(ncid,'bottom_top');   [~, nz]=netcdf.inqDim(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
        [nx ny]=size(x);   wdir=zeros(nx,ny,memsize); 
      end
      varid  =netcdf.inqVarID(ncid,'U');     u_stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
      varid  =netcdf.inqVarID(ncid,'V');     v_stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
      u=(u_stag(1:nx,:)+u_stag(2:nx+1,:))*0.5;   v=(v_stag(:,1:ny)+v_stag(:,2:ny+1))*0.5;
      wspd=(u.^2+v.^2).^0.5;
      %---
      umean=umean+u(1:int:nx,1:int:ny)/memsize;    vmean=vmean+v(1:int:nx,1:int:ny)/memsize;
      cmean=cmean+u./wspd/memsize;    smean=smean+v./wspd/memsize;
      netcdf.close(ncid)
    end %member
    R=(cmean.^2+smean.^2).^0.5; 
    sprd=(-2*log(R)).^0.5*180./pi;
%----
    xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
%}
%--plot----
    plotvar=sprd;
    plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
    figure('position',[100 200 600 500]) 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
    %---wind barb
    windmax=15;  scale=15;
    windbarbM_mapVer(xi,yi,umean,vmean,scale,windmax,[0.05 0.02 0.5],0.8)
    windbarbM_mapVer(plon(1)+0.2,plat(1)+0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
    m_text(plon(1)+0.21,plat(1)+0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
    %
    load('zhmean_40.mat');
    [c hp]=m_contour(x,y,zh_mean,[40 40],'color',[0.2 0.2 0.2],'LineWidth',1.1);
    %
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);    
    %
    mem=num2str(memsize);
    %tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',', mem',mem,')'];  
    tit=[varinam,'  ',s_hr,minu,'z  (with ',mem,' members)'];  
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_m',mem];
    %print('-dpng',outfile,'-r400')       
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  
    %
%}
end     % time

