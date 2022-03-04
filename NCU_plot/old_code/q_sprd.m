%function q_sprd(hr,expri,varind)
%clear
hr=18; expri='MRcycle06';   varind=2;

% hr : time
% expri : experiment name

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_red.mat'
%----set---- 
if varind==1; 
    vari0='QVAPOR'; vari='qv spread'; filenam=[expri,'_qv-sprd_']; 
    L=[0.6 0.8 1 1.2 1.3 1.4 1.5 1.6 1.7];
elseif varind==2; 
    vari0='QRAIN';  vari='qr spread'; filenam=[expri,'_qr-sprd_'];
    L=[0.2 0.35 0.5 0.65 0.8 0.95 1.1 1.25 1.4 ];
end
indir=['/SAS002/pwin/expri_241/morakot_en_',expri];
%indir=['/SAS004/pwin/wrfout_morakot_',expri];
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
%----
cmap=colormap_red;
%plon=[111 136]; plat=[12 36];
plon=[118.5 122.5]; plat=[21.65 25.65];
lev=6;
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='09';   s_hr='00';
   else
     s_date='08';   s_hr=num2str(ti);
   end     
   for mi=1:40   
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];
       %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
     else
       infile=[indir,'/pert',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];
       %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
     end
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
   [nx ny nz]=size(q);
   var=q*10^3;
   var_lev=var(:,:,lev);
   var_all(:,mi)=reshape(var_lev,nx*ny,1);   
%---     
   netcdf.close(ncid)
   end  
%---
   sprd=spread(var_all);
   p_sprd=reshape(sprd,nx,ny);
   pmin=min(min(p_sprd));
   if pmin<0.05; pmin=0; end
%---plot
   L2=[pmin,L];
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,p_sprd,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   %m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (lev',num2str(lev),')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'.png'];
   %saveas(gca,outfile,'png');
  %}
%---    

end 
