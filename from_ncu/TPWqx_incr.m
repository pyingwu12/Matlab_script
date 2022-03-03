function TPWqx_incr(hr,minu,expri)
%-------------------------------------------------------
% QRAIN increment (anal-fcst) after DA
%-------------------------------------------------------

%clear all
close all

%hr=0:1;   minu='30';    expri='e10';  
vari='QVAPOR';
wid=1; lev=12;  int=6;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS009/pwin/expri_whatsmore/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/what_shao/',expri];
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
L=[-7 -5 -3 -2 -1 -0.5 0.5 1 2 3 5 7 ];
% L=[-2.5 -2 -1.5 -1 -0.5 -0.1 0.1 0.5 1 1.5 2 2.5];  % QCLOUD
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
s_vari=lower(vari(1:2));
varinam=['Total-',s_vari,' increment'];  filenam=[expri,'_TPW-',s_vari,'-incr_'];
if wid~=0; filenam=[filenam,'wind_']; end
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
g=9.81;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,'/output/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqDimID(ncid,'bottom_top');    [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'south_north');   [~, ny]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'west_east');     [~, nx]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');   x =double(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'XLAT');    y =double(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,vari);      qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'U');      u_stag  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]); 
   varid  =netcdf.inqVarID(ncid,'V');      v_stag  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]); 
   netcdf.close(ncid)
  %---integrate TPW---
   P=(pb+p);  
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW1=sum(tpw,3)./g;
   %---
   u1=(u_stag(1:end-1,:)+u_stag(2:end,:))*0.5;
   v1=(v_stag(:,1:end-1)+v_stag(:,2:end))*0.5;
   spd1=(u1.^2+v1.^2).^0.5;
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,vari);      qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'U');      u_stag  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]); 
   varid  =netcdf.inqVarID(ncid,'V');      v_stag  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]); 
   netcdf.close(ncid)
  %---integrate TPW---
   P=(pb+p);   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW2=sum(tpw,3)./g; 
  %----
   u2=(u_stag(1:end-1,:)+u_stag(2:end,:)).*0.5;
   v2=(v_stag(:,1:end-1)+v_stag(:,2:end)).*0.5;  
   spd2=(u2.^2+v2.^2).^0.5;
%------------------    
   incr=TPW2-TPW1;       
   uincr=u2-u1;   vincr=v2-v1;    incrspd=spd2-spd1;
   xi=x(1:int:end,1:int:end);  yi=y(1:int:end,1:int:end);
   uplot=uincr(1:int:end,1:int:end);   vplot=vincr(1:int:end,1:int:end);  
%
%---plot----
   plotvar=incr;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
   %qscale=0.01; wtxt=2;
   h1 = m_quiver(xi,yi,u1(1:int:end,1:int:end),v1(1:int:end,1:int:end),'color',[0.05 0.4 0.1]) ; % the '0' turns off auto-scaling
   set(h1,'AutoScale','on', 'AutoScaleFactor', 2.5)
   %hU = get(h1,'UData');   hV = get(h1,'VData') ;
   %set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2);

%   h1 = m_quiver(plon(1)+0.1,plat(2)-0.2,wtxt,0,0,'color',[0.8 0.02 0.1]) ; % the '0' turns off auto-scaling
%   hU = get(h1,'UData');   hV = get(h1,'VData') ;
%   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.3,'MaxHeadSize',300);
%   set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on')
%   m_text(plon(1)+0.1,plat(2)-0.32,[num2str(wtxt),' m/s'],'color',[0.8 0.02 0.1],'fontsize',12)

   m_contour(x,y,uincr,[1.5 1.5],'color',[0.01 0 0.9],'linewidth',1.2);
   m_contour(x,y,uincr,[-1.5 -1.5],'--','color',[0.01 0.6 0.9],'linewidth',1.2);
   m_contour(x,y,vincr,[1.5 1.5],'color',[0.9 0 0.01],'linewidth',1.2);
   m_contour(x,y,vincr,[-1.5 -1.5],'--','color',[0.9 0.01 0.6],'linewidth',1.2);
    %
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
%   m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.9);    
    %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu];   print('-dpng',[outfile,'.png'],'-r450')       
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);     
end    
