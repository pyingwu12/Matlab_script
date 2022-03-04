clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')

expri='e02';    sth=0;  hrs=24;  date=25;  xtick=['08';'14';'20';'02';'08'];

%----set---- 
vari='10m wind at Douliou';   filenam=[expri,'_wind10m-point_dl']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
%xp=72; yp=131;
xp=50; yp=86;
s_mon='10';
%
%ni=0;
hrs=hrs+1;
for ni=1:hrs
    ti=sth+ni-1;
%---set filename---    
      hrday=fix(ti/24);  ti=ti-24*hrday;    s_date=num2str(date+hrday);    %%%
      if ti<=9;  s_hr=['0',num2str(ti)];  else   s_hr=num2str(ti);  end   %%%   
%    if ti==24
%      s_date='25';   s_hr='00';
%    else
%      s_date='24';   
%      if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end
%    end     
%===mean===
   infile=[indir,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00_mean'];
   ncid = netcdf.open(infile,'NC_NOWRITE');   
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');     hgt.m =netcdf.getVar(ncid,varid); 
   
   varid  =netcdf.inqVarID(ncid,'U');       u.stag  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'V');       v.stag  =(netcdf.getVar(ncid,varid));
   [nx ny]=size(x);  nz=size(ph,3)-1; 
   
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;   
   sp=(u.unstag.^2+v.unstag.^2).^0.5;    
   %---
   g=9.81;  
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;  
   %-
   hgt.iso=double(hgt.m)+10; 
   X=squeeze(zg(xp,yp,:));
   Y=squeeze(sp(xp,yp,:));     
   sp_mean(ni)=interp1(X,Y,hgt.iso(xp,yp),'linear');    
   %---
   netcdf.close(ncid)
%===spread===
   for mi=1:40  
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     else
       infile=[indir,'/pert',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     end        
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'U');       u.stag  =(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'V');       v.stag  =(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 

     u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
     sp=(u.unstag.^2+v.unstag.^2).^0.5;  
     %
     P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
     zg=double(PH)/g;  
     X=squeeze(zg(xp,yp,:));
     Y=squeeze(sp(xp,yp,:));     
     sp_ens(mi)=interp1(X,Y,hgt.iso(xp,yp),'linear');     
     netcdf.close(ncid)
   end %member
   %---   
   sp_sprd(ni)=spread(sp_ens); %%% PBL height spread at P(xp,yp), ni changes with time 
   %---
end %time
%}
%---plot
%%
figure('position',[100 100 700 500])
plot(1:hrs,sp_mean,'color',[0.05 0.2 0.3],'LineWidth',3); hold on
plot(1:hrs,sp_sprd,'color',[0.1 0.5 0.65],'LineWidth',3)

set(gca,'XLim',[1 ni],'YLim',[0 3.5],'XTick',[1 7 13 19 25],'XTickLabel',xtick,...
    'fontsize',14,'LineWidth',1)
xlabel('Time (LST)');   ylabel('speed (m/s)');
legend('ensemble mean','spread')   

tit=[expri,'  ',vari,'  ',s_mon,'/',num2str(date),'  (',num2str(lon(xp,yp)),'°E , ',num2str(lat(xp,yp)),'°N)'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,s_mon,num2str(date),'.png'];
print('-dpng',outfile,'-r400')   
%}   
   