clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%-----------set filename---------------------------
nn=198;

for h=15:20;
  umean=zeros(nn,nn,27); vmean=zeros(nn,nn,27);  ind=0;

    if h==24
     date='09';  hr='00';
    else
     date='08';  hr=num2str(h);
    end  

    infile=['/SAS004/pwin/wrfout_morakot_sing_1200/wrfout_d03_2009-08-',date,'_',hr,':00:00'];

% ------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
%
   varid  =netcdf.inqVarID(ncid,'Times');
    time=netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');
    u  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');
    v =netcdf.getVar(ncid,varid);
    
   ui=(u(1:nn,:,:)+u(2:nn+1,:,:)).*0.5;
   vi=(v(:,1:nn,:)+v(:,2:nn+1,:)).*0.5; 
   


save(['wind_',hr,'.mat'],'x','y','ui','vi')

end
%{
figure
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
h=m_quiver(x,y,umean(:,:,1),vmean(:,:,1),'k');
set(h,'linestyle','none');
m_grid('fontsize',12);
%m_gshhs_h('color','k');
%}
% eh=num2str(i+str);
% sh=num2str(str);
% hourtitle=['single wrf rain (',sh,'z to ',eh,'z)'];
%  title(hourtitle,'fontsize',13)
% outfile=['sing_accum_',sh,eh,'.png'];
%  saveas(gca,outfile,'png');



