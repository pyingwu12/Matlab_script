clear; 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
%load '/work/pwin/data/colormap_pbl.mat'; cmap=colormap_pbl;

expri='e01';   hr=0:24;  

%----set---- 
vari='Theta mean at Taoyuan';   filenam=[expri,'_T-mean_point']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS007/pwin/expri_lider201511/lider_',expri];
L=[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.2 1.5 1.7 2 2.3 2.7];
xp=72; yp=131;   g=9.81;  
hei=50:50:3000;  
%hei=100:200:18000; 
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
   infile=[indir,'/wrfout_d02_2015-11-',s_date,'_',s_hr,':00:00_mean'];       
   %----read netcdf data--------     
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'T');     t=(netcdf.getVar(ncid,varid))+300;      
   varid  =netcdf.inqVarID(ncid,'PH');    ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');   phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);           x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);           y=double(lat);
   [nx ny nz]=size(t); 
   
   %tp(:,mi)=double(t(xp,yp,:));    %% model level    
   P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH(xp,yp,:))./g;
   tp=double(t(xp,yp,:));                                       %%% T above P(xp,yp)
   tp_hei(:,ni)=interp1(squeeze(zg),squeeze(tp),hei,'linear');  %%% interpolation to isoheight
%---
   netcdf.close(ncid)
   %disp([num2str(ti),'Z ok'])
end
%}
if min(min(tp_hei))<L(1); L2=[min(min(tp_hei)) L]; else L2=L;end
%---
figure('position',[1800 50 700 550])
[c hp]=contourf(hr,hei,tp_hei,25);  
colorbar;   cm=colormap(jet(15));  
%hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
set(gca,'XTick',[0 6 12 18 24],'XTickLabel',['08';'14';'20';'02';'08'],...
    'Ylim',[zg(1) hei(length(hei))],'YTick',0:1000:hei(length(hei)),'YTickLabel',0:hei(length(hei))/1000,...
    'fontsize',13.5)
xlabel('Time (LST)'); ylabel('Height (km)'); %ylabel('Model level');

tit=[expri,'  ',vari,'  (',num2str(lon(xp,yp)),'°E , ',num2str(lat(xp,yp)),'°N)'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,'.png'];
print('-dpng',outfile,'-r300')   
%}