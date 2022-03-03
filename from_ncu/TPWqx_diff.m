%function TPWqx_diff(expri1,expri2)
%-------------------------------------------------------
% Difference(exp1-exp2) of integrate <vari>(qv,qr....) between expri1 to expri2  (DA cycle & forecasting time)
%-------------------------------------------------------

clear all
close all

vari='QVAPOR';
hr=2;  expri1='e11';  expri2='e10'; minu='00';   figtit1='L1204';   figtit2='S1204' ;
%hr=2;  expri1='e41';  expri2='e10';   figtit1='S2404';   figtit2='S1204' ;
%hr=2;  expri1='e11';  expri2='e10';   figtit1='L1204';   figtit2='S1204' ;
%hr=2;  expri1='e01';  expri2='e02';   figtit1='L3604';   figtit2='S3604' ;

wid=1; lev=12; int=5;

%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/analmean';   type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/';
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5];
%L=[-4 -3 -2 -1 -0.5 -0.2 0.2 0.5 1 2 3 4];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
%load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(2:14,:);
%------
s_vari=lower(vari(1:2));
varinam=['total-',s_vari,];  filenam=[expri1,'diff',expri2,'_','TPW',s_vari,'_'];
if wid~=0; filenam=[filenam,'wind_']; end
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
g=9.81;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
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
%-----------
   diff=TPW1-TPW2;   
   xi=x(1:int:end,1:int:end);  yi=y(1:int:end,1:int:end);
   udiff=u1-u2; vdiff=v1-v2;
%   uplot=uincr(1:int:end,1:int:end);   vplot=vincr(1:int:end,1:int:end);
    
%---plot----
   plotvar=diff;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 200 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   %---
   if wid==1
   %windmax=15;  scale=15;
   %windbarbM_mapVer(xi,yi,u2(1:int:end,1:int:end),v2(1:int:end,1:int:end),scale,windmax,[0.15 0.2 0.45],0.6)
   %windbarbM_mapVer(plon(1)+0.21,plat(1)+0.2,windmax,0,25,windmax,[0.1 0.05 0.45],1)
   %m_text(plon(1)+0.215,plat(1)+0.2,num2str(windmax),'color',[0.1 0.05 0.45],'fontsize',13)
   %---plot diffenence of wind
   qscale=0.1; wtxt=1;  vcolor=[0.1 0.15 0.1];  tcolor=[0.8 0.1 0.2];
   h1 = m_quiver(xi,yi,udiff(1:int:end,1:int:end),vdiff(1:int:end,1:int:end),0,'color',vcolor); 
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2);
   %
   h1 = m_quiver(plon(1)+0.1,plat(2)-0.2,wtxt,0,0,'color',tcolor); 
   hU = get(h1,'UData');  hV = get(h1,'VData') ; 
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.3,'MaxHeadSize',300);
   set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on')
   m_text(plon(1)+0.1,plat(2)-0.32,[num2str(wtxt),' m/s'],'color',tcolor,'fontsize',12)
   end
   %---
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);  xlabel(hc,'(Kg/m^2)') 
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   %
   %tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];
   %title(tit,'fontsize',15)

   tit=['PW   ',figtit1,'-',figtit2];
   title(tit,'position',[-0.0235 0.029],'fontsize',16);

   outfile=[outdir,'/',filenam,s_hr,minu,'_',type];  %print('-dpng',outfile,'-r400')       
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
end    
