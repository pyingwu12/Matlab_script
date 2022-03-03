%function wind_sing(expri)
%-------------------------------------------------------
% Plot wind vector and speed(shaded) when spid~=0
%-------------------------------------------------------

clear all
close all

hr=0;  minu='00';  expri='largens';   lev=12; 
% DA or forecast time---
infilenam='wrfmean';    type='mean';
%infilenam='wrfout';   type='sing';
%infilenam='output/fcstmean';   type=infilenam(8:11) %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';     % time setting
%indir=['/SAS009/pwin/expri_cctmorakot/',expri];
%indir=['/SAS009/pwin/expri_morakotEC/',expri]; 
%indir=['/SAS009/pwin/expri_whatsmore/',expri];  
indir=['/SAS009/pwin/expri_largens/',expri];
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
indir2=['/work/pwin/data/largens_wrf2obs_',expri];
L=[1 2 3 4 5 6 8 10 12 14 16 18 20];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_wind2.mat';  cmap=colormap_wind2; 
%---
varinam='wind speed';  filenam=[expri,'_wspd_'];  
plon=[118.9 121.9]; plat=[20.65 24.35];
int=6;
rad3=[120.8471 21.9026 42];
rad4=[120.0860 23.1467 38];
 
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string   
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    x =netcdf.getVar(ncid,varid,'double'); 
   varid  =netcdf.inqVarID(ncid,'XLAT');     y =netcdf.getVar(ncid,varid,'double'); 
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   [nx ny]=size(x);
%   vrm3=vr_cal_wrf2obs(ncid,x,y,rad3,lev,nx,ny,1.8e5);
%   vrm4=vr_cal_wrf2obs(ncid,x,y,rad4,lev,nx,ny,1.8e5);

   netcdf.close(ncid)
   [nx ny]=size(x); 
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   spd=(u.unstag.^2+v.unstag.^2).^0.5;
   plotvar=spd(:,:,lev);
   isotype=['lev',num2str(lev)];
%-------read wrf2obs data---------------
%   infile2=[indir2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%   A=importdata(infile2);
%   lon=A(:,5); lat=A(:,6);  vr=A(:,8);
%   fin1=find(vr~=-9999 & A(:,2)==0.5 & mod(A(:,3)-3,15)==0 & A(:,4)<=23 & A(:,4)>3 & mod(A(:,4)-3,10)==0 );
%   fin2=find(vr~=-9999 & A(:,2)==0.5 & mod(A(:,3)-3,10)==0 & A(:,4)<=43 & A(:,4)>23 & mod(A(:,4)-3,10)==0 );
%   fin3=find(vr~=-9999 & A(:,2)==0.5 & mod(A(:,3)-3,5)==0 & A(:,4)<=113 & A(:,4)>43 & mod(A(:,4)-3,10)==0);
%   fin=[fin1', fin2', fin3'];
%   lon=lon(fin); lat=lat(fin);  vr=vr(fin);
%------------------------------
   xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
   uplot=u.unstag(1:int:nx,1:int:ny,lev);   vplot=v.unstag(1:int:nx,1:int:ny,lev);
%
%---plot---      
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   figure('position',[100 200 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
   cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1) 
   hold on
   %---plot wind barb---
   windmax=15;  scale=15;
   windbarbM_mapVer(xi,yi,uplot,vplot,scale,windmax,[0.05 0.02 0.5],0.8)
   windbarbM_mapVer(plon(1)+0.2,plat(2)-0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   %---plot Vr---
%   m_contour(x,y,vrm3,[0 0],'color',[0.1 0.1 0.5],'linewidth',2,'linestyle','--');
%   m_contour(x,y,vrm4,[0 0],'color',[0.5 0.1 0.1],'linewidth',2,'linestyle','--');
%   hp=plot_point2(abs(vr),lon,lat,cmap,L);
   %--- 
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color',[0.3 0.3 0.3],'LineWidth',0.8)
   %
   m_plot(rad3(1),rad3(2),'^','color',[0.1 0.1 0.5],'MarkerFaceColor',[0.1 0.1 0.5],'MarkerSize',10)
   m_plot(rad4(1),rad4(2),'^','color',[0.5 0.1 0.1],'MarkerFaceColor',[0.5 0.1 0.1],'MarkerSize',10)

%   lonrad=120.8471; latrad=21.9026;
%   m_plot(,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',8)
%   lonrad=120.086; latrad=23.1467;
%   m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',8)
   %---
   %tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,')'];  
   tit=['Wind (ensmeble mean) 0000 UTC'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
%}   
end  %ti

