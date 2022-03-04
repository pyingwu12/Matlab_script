clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%-----------set filename---------------------------
for i=1:7;
  if i==7
   infile='/SAS004/pwin/wrfout_morakot_ori_1800/wrfout_d03_2009-08-09_00:00:00';        
  else 
   h=i+17;
   hour=num2str(h);
   infile=['/SAS004/pwin/wrfout_morakot_ori_1800/wrfout_d03_2009-08-08_',hour,':00:00'];
  end
%------read netcdf data--------
  ncid = netcdf.open(infile,'NC_NOWRITE'); 
%
  varid  =netcdf.inqVarID(ncid,'Times');
   time{i}=netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'XLONG');
   lon{i} =netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'XLAT');
   lat{i} =netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'ZNU');
   eta{i} =netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'RAINC');
   rc{i}  =netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'RAINNC');
   rnc{i} =netcdf.getVar(ncid,varid);
end
%-------x y-------------------------------
x=double(lon{1,1});
y=double(lat{1,1});
%-------rain------------------------------
for i=2:7
 rainc=rc{1,i}-rc{1,i-1};
 rainnc=rnc{1,i}-rnc{1,i-1};
 rain(:,:,i-1)=double(rainc+rainnc);
end
load '/work/pwin/data/heighti.mat';
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
for k=1:6;
acci(:,:,k)=griddata(x,y,rain(:,:,k),xi,yj,'cubic');
for j=1:81
    for i=1:41
        if heighti(j,i)<=0. || heighti(j,i)==NaN
            acci(j,i,k)=NaN;
        end
    end
end
end
%


%---------plot-----------------------------
load '/work/pwin/data/colormap_rain.mat';
for i=1:6
figure
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c h]=m_contourf(xi,yj,acci(:,:,i),17);
set(h,'linestyle','none');
m_grid('fontsize',12);
m_gshhs_h('color','k');
hc=colorbar;
colormap(colormap_rain);
caxis([0 200]);
nh1=num2str(i+17);
nh2=num2str(i+18);
 hourtitle=['ori wrf rain ( ',nh1,'z to ',nh2,'z )'];
  title(hourtitle,'fontsize',13)
 outfile=['ori_accum_1hr_',nh1,nh2,'.png'];
  saveas(gca,outfile,'png');
end

