clear
close all
addpath('/work/kjlin/matlab/m_map/')
%-----------set filename---------------------------
for i=1:7;
  if i==7
   infile=['/SAS004/pwin/wrfoutput/wrfout_d03_2009-08-09_00:00:00'];        
  else 
   h=i+17;
   hour=num2str(h);
   infile=['/SAS004/pwin/wrfoutput/wrfout_d03_2009-08-08_',hour,':00:00'];
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
  varid  =netcdf.inqVarID(ncid,'LANDMASK'); 
   landm{i} =netcdf.getVar(ncid,varid) ;
end
%-------x y-------------------------------
x=lon{1,1};
y=lat{1,1};
%-------rain------------------------------
for i=2:7
 rainc=rc{1,i}-rc{1,1};
 rainnc=rnc{1,i}-rnc{1,1};
 rain(:,:,i-1)=rainc+rainnc;
end
%-------land------------------------------
nn=length(x);
land=landm{1,1};
for i=1:nn;
 for j=1:nn;
  if (land(i,j)==0)
   rain(i,j,:)=0;
  end
  if(rain(i,j)<=10.0)
   rain(i,j,:)=nan;
  end 
 end
end
%
%---------plot-----------------------------
for i=1:1
figure
m_proj('miller','lon',[117 125],'lat',[20 27])
[cs h]=m_contourf(x,y,rain(:,:,i));
set(h,'linestyle','none');
m_grid('xtick',5,'ytick',5, 'box','fancy',  'tickdir','in', 'fontsize',14)
m_coast('color','k','linewidth',1);
colorbar
set(gca,'Clim',[0 350]) 
 nh=num2str(i);
 hourtitle=['Accumulated precipitation (',nh,'hour)'];
  title(hourtitle,'fontsize',14)
 outfile=['rain_',nh,'hour_accum.jpg'];
 % saveas(gca,outfile,'jpg');
end
%}



