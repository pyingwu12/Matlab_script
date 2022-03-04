function wind_mean(hr,expri,spid)
% hr :time
% expri : experiment name
% spid : if spid==0, only plot vector. else, plot both vector and speed.

%spid=1; hr=18; expri='MRcycle05';   %test
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_wind.mat'
%----set----
vari='wind';   filenam=[expri,'_wind_'];  type='mean';  
indir=['/SAS002/pwin/expri_241/morakot_en_',expri];
%indir=['/SAS004/pwin/wrfout_morakot_',expri];
outdir=['/work/pwin/plot_cal/Wind/',expri,'/'];
lev=8;
%----
cmap=colormap_wind;
L=[3 6 9 12 15 18 21 24 26 28 30 32 34 36 38 40];
%---
if spid~=0; filenam=['cntf_',filenam]; end
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
   varid  =netcdf.inqVarID(ncid,'U');
    u  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');
    v =netcdf.getVar(ncid,varid);
%----calculate wind U, V and Speed---
   nn=size(v,1);
   umean=(u(1:nn,:,:)+u(2:nn+1,:,:)).*0.5;
   vmean=(v(:,1:nn,:)+v(:,2:nn+1,:)).*0.5;    
   sp=(umean.^2+vmean.^2).^0.5;   
%---TC center
   bestx(15:21)=[120.4 120.4 120.4 120.4 120.4 120.4 120.4 ];
   besty(15:21)=[25.05 25.1 25.15 25.2  26.033 26.867 27.7 ];
  % [lonc latc]=center(ncid);
%====plot set====
   xi=x(1:5:196,1:5:196);   yi=y(1:5:196,1:5:196);
   uplot=umean(1:5:196,1:5:196,:);   vplot=vmean(1:5:196,1:5:196,:);
%---plot
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   if spid~=0
     L2=[min(min(sp(:,:,lev))),L];
     [c hp]=m_contourf(x,y,sp(:,:,lev),L2);   set(hp,'linestyle','none');
     colorbar;   cm=colormap(cmap);   
     hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
   end
   hold on
   m_plot(bestx(ti),besty(ti),'xk','MarkerSize',8,'LineWidth',2.3);
  % m_plot(lonc,latc,'o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0],'MarkerSize',4.8); %center
%---vector & legend---
   if spid==0
     % Max, legend
     s=(uplot.^2+vplot.^2).^0.5; 
     Ma=max(max(s(:,:,lev)));   Mav=ceil(Ma/5)*5;  
     uplot(28,12,lev)=Mav;   vplot(28,12,lev)=0;
     m_text(122.65,21.95,num2str(Mav),'color','k');
   end
   hq=m_quiver(xi,yi,uplot(:,:,lev),vplot(:,:,lev),1.5,'k');
   set(hq,'LineWidth',1.5)
%---
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',1);
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,', lev',num2str(lev),' )'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',type,'.png'];
   print('-dpng',outfile,'-r350')    
   netcdf.close(ncid)
end


