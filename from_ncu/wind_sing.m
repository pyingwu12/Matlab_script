%function wind_sing(expri)
%-------------------------------------------------------
% Plot wind vector and speed(shaded) when spid~=0
%-------------------------------------------------------

clear all
close all

hr=2;  minu='00';  expri='e01';   
isoid=0;    spid=0;    int=5; %interval for plot wind vector
%
if isoid==0;   lev=10;   else    hgt_w =1000;    end  % level or height for plot
% DA or forecast time---
%infilenam='wrfmean';    type='mean';
infilenam='wrfout';   type='sing';
%infilenam='output/fcstmean';   type=infilenam(8:11) %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';     % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%L=[1 3 5 7 9 11 13 15 17 19 21 23 25]; %IOP8
L=[1 2 3 4 5 6 8 10 12 14 16 18 20 ]; %IOP8
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_wind2.mat';  cmap=colormap_wind2; 
%---
varinam='wind';  filenam=[expri,'_wind_'];  
if spid~=0; filenam=['sp_',filenam]; end
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
%plon=[117.5 122.5]; plat=[20.5 25.65];
g=9.81;  
 
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string   
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    x =double(netcdf.getVar(ncid,varid));     %x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     y =double(netcdf.getVar(ncid,varid));     %y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   [nx ny]=size(x); nz=size(u.stag,3);
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   %---interpolation to constant-height above surface when isoid~=0
   if isoid~=0
      P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)/g;   
      hgtiso=double(hgt)+hgt_w; 
      for i=1:nx
       for j=1:ny
       X=squeeze(zg(i,j,:));
       Y=squeeze(u.unstag(i,j,:));     u.iso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       Y=squeeze(v.unstag(i,j,:));     v.iso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       end
      end      
      u.plot=u.iso(1:int:nx,1:int:ny,:);   v.plot=v.iso(1:int:nx,1:int:ny,:); 
      plotvar=(u.iso.^2+v.iso.^2).^0.5;
      isotype=[num2str(hgt_w/1000),'km'];
   else
      spd=(u.unstag.^2+v.unstag.^2).^0.5;
      uplot=u.unstag(1:int:nx,1:int:ny,lev);   vplot=v.unstag(1:int:nx,1:int:ny,lev); 
      plotvar=spd(:,:,lev);
      isotype=['lev',num2str(lev)];
   end   
   xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
   %---plot---      
   %%
   figure('position',[100 200 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %---speed shaded--- 
    if spid~=0  
     pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
     [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
     cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
     hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1) 
     hold on
    end
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color',[0.3 0.3 0.3],'LineWidth',0.8);
   %
   windmax=15;  scale=15;
   windbarbM_mapVer(xi,yi,uplot,vplot,scale,windmax,[0.05 0.02 0.05],0.8)
   windbarbM_mapVer(plon(1)+0.2,plat(2)-0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   %---
   hold on
   [c2,hc]=m_contour(x,y,u.unstag(:,:,lev),[10 15],'color',[0.05 0.5 0.8],'linewidth',1);
     clabel(c2,hc,'fontsize',11,'color',[0.05 0.4 0.7],'LabelSpacing',400);
   [c2,hc]=m_contour(x,y,v.unstag(:,:,lev),[10 15],'color',[0.8 0.05 0.5],'linewidth',1);
     clabel(c2,hc,'fontsize',11,'color',[0.7 0.05 0.4],'LabelSpacing',400);
   %
   %===obs station wind====
%   [lon lat wspd wdir]=wind_obs_read(s_hr,year,mon,date,date);
%   lon=lon(wspd>0);  lat=lat(wspd>0);  wdir=wdir(wspd>0);  wspd=wspd(wspd>0);
%   wdir=wdir.*pi./180;
%   u.obs=-wspd.*sin(wdir);   v.obs=-wspd.*cos(wdir);  
%   windbarbM_mapVer(lon,lat,u.obs,v.obs,scale,windmax,[0.8 0.1 0.1],0.8)
   %=======================
%    hold on  % terrain
%    m_contour(x,y,hgt,[1000 1000],'color',[0.55 0.55 0.55],'LineWidth',1);
   %---
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
%     
end  %ti

