%
clear; 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_pbl.mat'; cmap=colormap_pbl;

expri='e01';   hr=6;  

%----set---- 
vari='Theta spread';   filenam=[expri,'_T-sprd-HT_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS007/pwin/expri_lider201511/lider_',expri];
L=[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.1 1.3 1.5 1.8 2.1 2.4];
xp=72; yp=131;  g=9.81;

%
ni=0;
for ti=hr
    ni=ni+1;
%---set filename---    
   if ti==24
     s_date='06';   s_hr='00';
   else
     s_date='05';   
     if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end
   end     
   %
   infile=[indir,'/wrfout_d02_2015-11-',s_date,'_',s_hr,':00:00_mean'];     
     %----read netcdf data--------     
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'PH');       ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);           x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);           y=double(lat);
   [nx ny nz]=size(ph); 
   P0=(phb+ph);   PH=(P0(:,:,1:nz-1)+P0(:,:,2:nz)).*0.5;
   zg=double(PH)./g;
%---
   netcdf.close(ncid)
end

height_lat=squeeze(zg(:,yp,:));
%[x_lon hei]=meshgrid(x(:,yp),zg(xp,yp,:));
figure('position',[1800 100 700 500])
for i=1:nz-1;
 height=height_lat(:,i);
 plot(x(:,yp),height); hold on
end

%contour(x_lon,hei,height_lat')
%{
xaxis=0:ti; yaxis=1:length(hei);
%L2=L; L2(1)=min(min(sprd));
%if min(min(sprd))<L(1); L(1)=min(min(sprd)); end
L2=[min(min(sprd)) L];
%---
figure('position',[1800 100 700 500])

[c hp]=contourf(xaxis,hei,sprd,L2);  
%hp=pcolor(double(sprd));

colorbar;   cm=colormap(cmap);  %caxis([0.1 1.6])
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
set(gca,'XTick',[0 6 12 18 24],'XTickLabel',[08 14 20 02 08],...
    'YTick',1000:18000,'YTickLabel',1:18,'fontsize',14)
xlabel('Time (LST)'); ylabel('Height (km)'); %ylabel('Model level');

tit=[expri,'  ',vari,'  (time-height)'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,'.png'];
print('-dpng',outfile,'-r300')   
%}