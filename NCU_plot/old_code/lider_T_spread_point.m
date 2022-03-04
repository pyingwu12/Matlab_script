clear; 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_pbl.mat'; cmap=colormap_pbl;

expri='e02';   sth=0; hrs=24;  date=25; 
%hei=50:50:5000;    filenam=[expri,'_T-sprd_point_low']; 
hei=100:200:18000; filenam=[expri,'_T-sprd_point']; 
%----set---- 
vari='Theta spread at Douliou';   %filenam=[expri,'_T-sprd_point']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
L=[0.05 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1];
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
      varid  =netcdf.inqVarID(ncid,'XLONG');
       lon =netcdf.getVar(ncid,varid);           x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');
       lat =netcdf.getVar(ncid,varid);           y=double(lat);
      [nx ny nz]=size(t); 
     end
     P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
     %zg(:,mi)=double(PH(xp,yp,:))./g;
     %tp(:,mi)=double(t(xp,yp,:));    %% model level    
     %---
     zg=double(PH(xp,yp,:))./g;
     tp=double(t(xp,yp,:));                                       %%% T above P(xp,yp)
     tp_hei(:,mi)=interp1(squeeze(zg),squeeze(tp),hei,'linear');  %%% interpolation to isoheight
%---
     netcdf.close(ncid)
   end %member
   %
   %sprd(:,ni)=spread(tp);  zgt(:,ni)=mean(zg,2);
   sprd(:,ni)=spread(tp_hei);   %%% T spread above P(xp,yp), ni changes with time
   disp([num2str(ti),'Z DONE'])
end
%}

if min(min(sprd))<L(1); L2=[min(min(sprd)) L]; else L2=[L(1) L];end
%zg_mean=mean(zgt,2);
%---
figure('position',[100 50 700 550])
[c hp]=contourf(1:hrs,hei,sprd,L2);    set(hp,'linewidth',0.5); 
%[c hp]=contourf(hr,1:nz,sprd,L2); 
colorbar;   cm=colormap(cmap);  
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
set(gca,'XTick',[1 7 13 19 25],'XTickLabel',['08';'14';'20';'02';'08'],...
    'Ylim',[zg(1) hei(length(hei))],'YTick',0:1000:hei(length(hei)),'YTickLabel',0:hei(length(hei))/1000,...
    'fontsize',13,'LineWidth',1)
%set(gca,'Ytick',5:5:45,'YTickLabel',round(zg_mean(5:5:45)))
xlabel('Time (LST)'); ylabel('Height (km)'); %ylabel('Model level');

tit=[expri,'  ',vari,'  ',s_mon,'/',num2str(date),'  (',num2str(lon(xp,yp)),'°E , ',num2str(lat(xp,yp)),'°N)'];
title(tit,'fontsize',14)
outfile=[outdir,filenam,s_mon,num2str(date),'.png'];
print('-dpng',outfile,'-r400')   
%}