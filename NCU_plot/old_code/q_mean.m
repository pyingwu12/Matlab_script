%function q_mean(hr,expri,varind)
%clear; 
hr=17:20; expri='orig';  varind=2;
% hr : time
% expri : experiment name

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat'
%----set----
if varind==1; 
    vari0='QVAPOR'; vari='qv'; 
    L=[13 13.5 14 14.5 15 15.5 16 16.5 17 17.5 18 18.5 19 19.5 20 20.5];
elseif varind==2; 
    vari0='QRAIN';  vari='qr';
    L=[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.4 1.6 1.8 2.0 2.2];
end
filenam=[expri,'_',vari,'_'];  type='mean';  
%indir=['/SAS002/pwin/expri_241/morakot_en_',expri];
indir=['/SAS004/pwin/wrfout_morakot_',expri];
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
%----
%plon=[111 136]; plat=[12 36];
plon=[118.5 122.5]; plat=[21.65 25.65];
cmap=colormap_qr2;
lev=6;
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='09';   s_hr='00';
   else
     s_date='08';   s_hr=num2str(ti);
   end     
   infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_mean'];
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,vari0);   q  =(netcdf.getVar(ncid,varid));
%---
   var=q*10^3;
   p_var=var(:,:,lev);
   pmin=min(min(p_var));
   if pmin<0.05; pmin=0; end
%====plot
   L2=[pmin,L];
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,p_var,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,', lev',num2str(lev),')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',type,'.png'];
   saveas(gca,outfile,'png')
%---    
   netcdf.close(ncid)
end    

%end
