function Bouy_sing(hr,minu,expri,lev)
%-------------------------------------------------------
%  plot (T-mean(T))
%-------------------------------------------------------
%clear all
%close all

%hr=2;  minu='45';  expri='e02';  lev=10;
%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/fcstmean';  type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];  % path of the experiments
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(8:12,:); 
%L=[-1.1 -0.9 -0.7 -0.5 -0.3 -0.1 0.1 0.3 0.5 0.7 0.9 1.1]*0.1;
L=[0 0.1 0.3 0.5]*0.1;
%---
varinam='Buoyancy';    filenam=[expri,'_Bouy_'];  
%plon=[118.9 121.8];   plat=[21 24.8];
plon=[118.9 121.8];   plat=[21 24.3];
 cp=1005;  % J/(K*kg)
 R=287.43;
 g=9.81;
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid =netcdf.inqDimID(ncid,'west_east'); [~, nx]=netcdf.inqDim(ncid,varid);
   varid =netcdf.inqDimID(ncid,'south_north'); [~, ny]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'T');        t  =netcdf.getVar(ncid,varid);   T=t+300;
   varid  =netcdf.inqVarID(ncid,'P');        p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');       pb =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');        w  =netcdf.getVar(ncid,varid);

   netcdf.close(ncid) 
%----------
   P=p+pb;
   temp=T.*(100000./P).^(-R/cp); %temperature   
   t_m=mean(mean(temp(:,:,lev)));
   B=g*( temp(:,:,lev)-repmat(t_m,nx,ny) )./temp(:,:,lev);
   B_low=sum(B,3);
   
%---plot---
   plotvar=B;  plotvar(plotvar<0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   %
   figure('position',[100 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [~, hp]=m_contourf(x,y,plotvar,10);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   %m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);      caxis([L(1) L(end)])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)   
   %
   hold on
   m_contour(x,y,w(:,:,lev),[1 1],'color',[0.4 0.1 0.05],'linewidth',1.3);
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (lev',num2str(lev(end)),')']; 
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_lev',num2str(lev(end))];
   %print('-dpng',outfile,'-r400')        
   % set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   % system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   % system(['rm ',[outfile,'.pdf']]);  
end  %ti
