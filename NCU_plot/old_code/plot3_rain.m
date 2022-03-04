clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%-----------set filename---------------------------
str=15;
for i=1:7;
   h=i+str-1;
   if h==24
   infile='/SAS004/pwin/wrfout_morakot_sing_1200/wrfout_d03_2009-08-09_00:00:00';
   else
   hour=num2str(h);
   infile=['/SAS004/pwin/wrfout_morakot_sing_1200/wrfout_d03_2009-08-08_',hour,':00:00'];
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
%x=double(x(1,:));
%y=double(y(1,:));
%[x y]=meshgrid(x,y);
%-------rain------------------------------
for i=2:7
 rainc=rc{1,i}-rc{1,1};
 rainnc=rnc{1,i}-rnc{1,1};
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
caxis([0 400]);
%set(gca,'YTickLabel',[0 50 100 150 200]);
 eh=num2str(i+str);
 sh=num2str(str);
 hourtitle=['single wrf rain (',sh,'z to ',eh,'z)'];
  title(hourtitle,'fontsize',13)
 outfile=['sing_accum_',sh,eh,'.png'];
  saveas(gca,outfile,'png');
end
%}


