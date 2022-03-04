%function iop8_qx_sprd(hm,expri,vari,lev)

%--------------------------------------------------------------------------
% plot 2-D spread of mixing ratio(Qxxxx) at level 'lev'
% lev=7~=1km, lev=9~=2km
%--------------------------------------------------------------------------

clear;  
hm=['00:00'];  expri='R06';   vari='QRAIN';  lev=7;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat';  cmap(2:10,:)=colormap_sprd([1 3 5 7 8 9 11 13 14],:); cmap(1,:)=[1 1 1];
%----set---- 
varit=[vari,' spread'];     filenam=[expri,'_',vari,'-sprd_']; 
indir=['/SAS007/pwin/expri_sz6414/',expri];
%indir=['/SAS007/sz6414/IOP8/Goddard/DA/e18',expri,'_all3'];
%indir='/SAS007/sz6414/IOP8/Goddard/back/input/';
%outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
outdir=['/work/pwin/plot_cal/IOP8/',expri];
%
mem=35; 
s_date='16';  dom='03';
num=size(hm,1);
%----
%L=[0.5 1 1.5 2 2.5 3 3.5 4];
L=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 1];
%plon=[118.35 121.65]; plat=[21.3 24.85];
plon=[118.85 121.85]; plat=[21.15 23.85];


%----
for ti=1:num;
   time=hm(ti,:);
%---set filename---     
   for mi=1:mem   
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/cycle0',nen,'/anal_d',dom,'_2008-06-',s_date,'_',time,':00'];
       %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
       %infile=[indir,'/wrfinput_nc_0',nen];
     else
       infile=[indir,'/cycle',nen,'/anal_d',dom,'_2008-06-',s_date,'_',time,':00'];
       %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
       %infile=[indir,'/wrfinput_nc_',nen];
     end
%----read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
     varid  =netcdf.inqVarID(ncid,vari);       q.m  =(netcdf.getVar(ncid,varid))*1000;
%---
     [nx ny ~]=size(q.m);
     q.line(:,mi)=reshape(q.m(:,:,lev),nx*ny,1);
     %
     netcdf.close(ncid)
   end  
%---
   q.sprd=spread(q.line);
   q.sprdplot=reshape(q.sprd,nx,ny);   
%---plot---
   plot.var=q.sprdplot;  plot.var(plot.var==0)=NaN;
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plot.var,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   cm=colormap(cmap);  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%---
   tit=[expri,'  ',varit,'  ',time(1:2),time(4:5),'z  (lev',num2str(lev),')'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,time(1:2),time(4:5),'_lev',num2str(lev),'.png'];
   print('-dpng',outfile,'-r400')
%---    

end 
