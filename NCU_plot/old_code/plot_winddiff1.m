clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%-----------set filename---------------------------
nn=198;
ind=0; 
dir{1}='wrfout_morakot_d03en_1200';
dir{2}='wrfout_morakot_d03enMR15_1500';

for h=15:20

for j=1:2
umean=zeros(nn,nn,27); vmean=zeros(nn,nn,27);
 
    if h==24
     date='09';
     hr='00';
    else
     date='08';   
     hr=num2str(h);
    end 

    infile=['/SAS004/pwin/',dir{j},'/wrfout_d03_2009-08-',date,'_',hr,':00:00_mean'];

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
    

   umean=(u(1:nn,:,:)+u(2:nn+1,:,:)).*0.5;
   vmean=(v(:,1:nn,:)+v(:,2:nn+1,:)).*0.5;  
  

   um{j}=umean;
   vm{j}=vmean;
   sp{j}=(umean.^2+vmean.^2).^0.5;

end

udiff=um{2}-um{1};
vdiff=vm{2}-vm{1};
spdiff=sp{2}-sp{1};


save(['wind_diff_',hr,'.mat'],'x','y','udiff','vdiff','spdiff','um','vm')

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



