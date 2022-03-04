clear; 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat'; cmap=colormap_sprd;

expri='e02';   sth=0;  hrs=24;  date=25; 
hei=0:10:1000; filenam=[expri,'_wind-sprd_point_1km_']; 
%hei=50:50:5000;    filenam=[expri,'_wind-sprd_point_']; 
%hei=100:200:18000; filenam=[expri,'_wind-sprd_point_18km_']; 
%----set---- 
vari='wind speed spread at Douliou';   %filenam=[expri,'_wind-sprd_point']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
L=[0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.6 0.7 0.8 0.9 1 1.1];
%xp=72; yp=131;   
xp=50; yp=86;
g=9.81;  s_mon='10';
%
%ni=0;
hrs=hrs+1;
for ni=1:hrs
    ti=sth+ni-1;
%---set filename---    
      hrday=fix(ti/24);  ti=ti-24*hrday;    s_date=num2str(date+hrday);    %%%
      if ti<=9;  s_hr=['0',num2str(ti)];  else   s_hr=num2str(ti);  end   %%%   
%====
   for mi=1:40
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     else
       infile=[indir,'/pert',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     end        
     %----read netcdf data--------     
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'T');     t=(netcdf.getVar(ncid,varid))+300;      
     varid  =netcdf.inqVarID(ncid,'PH');    ph =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'PHB');   phb =netcdf.getVar(ncid,varid); 
     if mi==1
      varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);    x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);    y=double(lat);
      [nx ny nz]=size(t); 
     end
     varid  =netcdf.inqVarID(ncid,'U');       u.stag  =(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'V');       v.stag  =(netcdf.getVar(ncid,varid));
     %--
     u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;       
     sp0=(u.unstag.^2+v.unstag.^2).^0.5;  
     %
     P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
     zg=double(PH(xp,yp,:))./g;
     sp=double(sp0(xp,yp,:));                                       %%% T above P(xp,yp)
     sp_hei(:,mi)=interp1(squeeze(zg),squeeze(sp),hei,'linear');  %%% interpolation to isoheight
%---
     netcdf.close(ncid)
   end %member
   %
   %sprd(:,ni)=spread(tp);  zgt(:,ni)=mean(zg,2);
   sprd(:,ni)=spread(sp_hei);   %%% T spread above P(xp,yp), ni changes with time
   disp([num2str(ti),'Z DONE'])
end
%}
%%
if min(min(sprd))<L(1); L2=[min(min(sprd)) L]; else L2=[L(1) L];end
%---
figure('position',[100 50 700 550])
[c hp]=contourf(1:hrs,hei,sprd,L2);    set(hp,'linewidth',0.5); 
%[c hp]=contourf(hr,1:nz,sprd,L2); 
cm=colormap(cmap);   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
set(gca,'XTick',[1 7 13 19 25],'XTickLabel',['08';'14';'20';'02';'08'],...
    'Ylim',[zg(1) hei(length(hei))],'YTick',0:1000:hei(length(hei)),'YTickLabel',0:hei(length(hei))/1000,...
    'fontsize',13,'LineWidth',1)
xlabel('Time (LST)'); ylabel('Height (km)'); %ylabel('Model level');

tit=[expri,'  ',vari,'  ',s_mon,'/',num2str(date),'  (',num2str(lon(xp,yp)),'°E , ',num2str(lat(xp,yp)),'°N)'];
title(tit,'fontsize',14)
outfile=[outdir,filenam,s_mon,num2str(date),'.png'];
print('-dpng',outfile,'-r400')   
%}