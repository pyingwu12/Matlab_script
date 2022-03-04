clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
load '/work/pwin/data/colormap_qr.mat'   
%-----------set filename---------------------------
member=1:40;  dire='wrfout_morakot_orig_1200'; type='member';  clim=[0 6];
expri='original';   vari='max qrain';   filenam='ori_maxqr_';  
hm='15:00';  %time
num=size(hm,1);
%---
for ti=1:num;
   time=hm(ti,:);
   for mi=member
      nen=num2str(mi);
      if mi<=9
        infile=['/SAS004/pwin/',dire,'/wrfout_d03_2009-08-08_',time,':00_0',nen];
      else
        infile=['/SAS004/pwin/',dire,'/wrfout_d03_2009-08-08_',time,':00_',nen];
      end
%------read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');   
      varid  =netcdf.inqVarID(ncid,'Times');
      wrftime=netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'XLONG');
      lon =netcdf.getVar(ncid,varid);   x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');
      lat =netcdf.getVar(ncid,varid);    y=double(lat);
      varid  =netcdf.inqVarID(ncid,'QRAIN');
      qr  =(netcdf.getVar(ncid,varid))*10^3;
      nx=size(qr,1); ny=size(qr,2);
%---
      for k=1:nx
         for l=1:ny
           qrmax(k,l)=max(qr(k,l,:)); 
         end
      end
%---plot---
      figure('position',[500 100 600 500])
      m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
      [c hp]=m_contourf(x,y,qrmax,16);   set(hp,'linestyle','none');
      hc=colorbar;    caxis(clim);   cm=colormap(colormap_qr);
      %[c hp]=m_contour(x,y,qrmax,[1 1],'color',[0.4 0.5 0.4],'LineWidth',1.5);   
      %clabel(c,hp,'fontsize',12,'rotation',0,'labelspacing',288)
      m_grid('fontsize',12);
      %m_coast('color','k');
      m_gshhs_h('color','k');
      tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z','  (',type,nen,')'];
      title(tit,'fontsize',15)
      outfile=[filenam,time(1:2),time(4:5),'_m',nen,'.png'];
      saveas(gca,outfile,'png');
   end
end