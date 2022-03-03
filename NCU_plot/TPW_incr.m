%-------------------------------------------------------
% TPW increment (anal-fcst) after DA
%-------------------------------------------------------

clear

hr=0;   minu='00';    expri='e02';  

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];       % path of the experiments
%indir=['/SAS009/pwin/expri_cctmorakot/',expri];
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri];
%outdir=['/SAS011/pwin/201work/plot_cal/morakot_shao/',expri];   % path of the figure output
L=[-7 -5 -3 -2 -1 -0.5 0.5 1 2 3 5 7 ];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='TPW increment';  filenam=[expri,'_TPW-incr_'];
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
plon=[118.3 122.85];  plat=[21.2 25.8];
g=9.8;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,'/output/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QCLOUD');  qc  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QICE');    qi  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QSNOW');   qs  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QGRAUP');  qg  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
  %---integrate TPW---
   qt=qr+qc+qv+qi+qg+qs;
   P=(pb+p);   [nx ny nz]=size(qr);
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qt(:,:,2:nz)+qt(:,:,1:nz-1)).*0.5 ) ;    
   TPW1=sum(tpw,3)./g;
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QCLOUD');  qc  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QICE');    qi  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QSNOW');   qs  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QGRAUP');  qg  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
  %---integrate TPW---
   qt=qr+qc+qv+qi+qg+qs;
   P=(pb+p);   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qt(:,:,2:nz)+qt(:,:,1:nz-1)).*0.5 ) ;    
   TPW2=sum(tpw,3)./g; 
%------------------    
   incr=TPW2-TPW1;    
%--plot----
   plotvar=incr;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
    %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu];    %print('-dpng',outfile,'-r400')  
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);     
end    
