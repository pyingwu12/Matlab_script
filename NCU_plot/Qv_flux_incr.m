%-------------------------------------------------------
% QVAPOR flux increment (anal-fcst) after DA
%-------------------------------------------------------

clear all
%close all

hr=0;   minu='00';    expri='e01';    lev=12;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
%L=[-7 -5 -3 -2 -1 -0.5 0.5 1 2 3 5 7 ];
 L=[-50 -40 -30 -20 -10 -5  5 10 20 30 40 50];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='Qv flux increment';  filenam=[expri,'_qv-flux-incr_'];
plon=[118.3 121.8];   plat=[21 24.3];
int=10;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,'/output/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
%   varid  =netcdf.inqDimID(ncid,'bottom_top');   [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'south_north');   [~, ny]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'west_east');   [~, nx]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');     lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');      lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');    qv  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'U');         u_stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'V');         v_stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
   u=(u_stag(1:nx,:)+u_stag(2:nx+1,:))*0.5;   v=(v_stag(:,1:ny)+v_stag(:,2:ny+1))*0.5;
   qvfu1=u.*qv*1000;    qvfv1=v.*qv*1000;
   qvfspd1=(qvfu1.^2+qvfv1.^2).^0.5;
   netcdf.close(ncid)
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'QVAPOR');    qv  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'U');         u_stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'V');         v_stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
   u=(u_stag(1:nx,:)+u_stag(2:nx+1,:))*0.5;   v=(v_stag(:,1:ny)+v_stag(:,2:ny+1))*0.5;
   qvfu2=u.*qv*1000;    qvfv2=v.*qv*1000;
   qvfspd2=(qvfu2.^2+qvfv2.^2).^0.5;
   netcdf.close(ncid)
%------------------    
   qvui=qvfu2(1:int:nx,1:int:ny)-qvfu1(1:int:nx,1:int:ny);
   qvvi=qvfv2(1:int:nx,1:int:ny)-qvfv1(1:int:nx,1:int:ny);
   qvspdi=qvfspd2-qvfspd1;      
%----
   xi=x(1:int:nx,1:int:ny);          yi=y(1:int:nx,1:int:ny);

%--plot----
   plotvar=qvspdi;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on
    %---wind barb
    windmax=100;  scale=15;
    windbarbM_mapVer(xi,yi,qvui,qvvi,scale,windmax,[0.02 0.9 0.05],0.8)
    windbarbM_mapVer(plon(1)+0.2,plat(1)+0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
    m_text(plon(1)+0.21,plat(1)+0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)    
   %----
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   m_coast('color','k');
%    m_gshhs_h('color','k','LineWidth',0.8);    
    %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z (lev',num2str(lev),')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_lev',num2str(lev)];   %print('-dpng',outfile,'-r400')       
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);     
%}
end    
