clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')

expri='e02';    sth=0;  hrs=24;   date=25;

%----set---- 
vari='PBLH';   filenam=[expri,'_PBLH-point_dl']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
%xp=72; yp=131;
xp=50; yp=86;
s_mon='10';  if sth<=9;  s_sth=['0',num2str(sth)];  else   s_hr=num2str(sth);  end
%
hrs=hrs+1;
for ni=1:hrs
   ti=sth+ni-1;
%---set filename---    
   hrday=fix(ti/24);  ti=ti-24*hrday;    s_date=num2str(date+hrday);    %%%
   if ti<=9;  s_hr=['0',num2str(ti)];  else   s_hr=num2str(ti);  end   %%%      
%===mean===
   infile=[indir,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00_mean'];
   ncid = netcdf.open(infile,'NC_NOWRITE');   
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PBLH');     pblh=(netcdf.getVar(ncid,varid));
   %---
   pblh_mean(ni)=double(pblh(xp,yp));  %%% PBL height ensemble mean at P(xp,yp), ni changes with time
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
     varid  =netcdf.inqVarID(ncid,'PBLH');       pblh=(netcdf.getVar(ncid,varid));  
     netcdf.close(ncid)
     %
     pblh_ens(mi)=double(pblh(xp,yp)) ;  %%% PBL height at P(xp,yp), mi changes with members    
   end %member
   %---
   pblh_sprd(ni)=spread(pblh_ens); %%% PBL height spread at P(xp,yp), ni changes with time 
   %---
end %time
%}
%---plot
figure('position',[100 100 700 500])
plot(1:hrs,pblh_mean,'color',[0.05 0.2 0.3],'LineWidth',3); hold on
plot(1:hrs,pblh_sprd,'color',[0.1 0.5 0.65],'LineWidth',3)

set(gca,'XLim',[1 ni],'YLim',[0 1300],'XTick',[1 7 13 19 25],'XTickLabel',['08';'14';'20';'02';'08'],...
    'fontsize',14,'LineWidth',1)
xlabel('Time (LST)');   ylabel('Height (m)');
legend('ensemble mean','spread')   

tit=[expri,'  ',vari,'  ',s_mon,'/',num2str(date),' ',s_sth,'z-',s_mon,'/',s_date,' ',s_hr,'z',...
      '  at Douliou (',num2str(lon(xp,yp)),'°E , ',num2str(lat(xp,yp)),'°N)'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,s_mon,num2str(date),s_sth,'.png'];
print('-dpng',outfile,'-r400')     
   