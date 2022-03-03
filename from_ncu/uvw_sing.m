%function uvw_sing(hr,expri,wid,isoid)
%-------------------------------------------------------
% u,v,w difference(exp1-exp2) between expri1 to expri2  (DA cycle & forecasting time)
%          wid=1-U, 2-V, 3-W
%-------------------------------------------------------
clear all
close all

hr=2;   expri='e01';    wid=[1 2];   isoid=0;   % 0:model level. ~=0:constant-height
%
if isoid==0; lev=10; else hgt_w=3000; end  % level or height for plot
%---DA or forecast time---
%infilenam='wrfmean';  minu='00';  type='mean';
infilenam='wrfout';  minu='00';   type='sing';
%infilenam='output/fcstmean'; minu='00'; type=infilenam(8:11); %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';   % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];    % path of the experiments
%indir=['/SAS009/pwin/expri_cctmorakot/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/morakot_shao/',expri];
%indir=['/SAS009/pwin/expri_morakotEC/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/morakot_EC/',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/what/',expri];
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[-15 -10 -7 -5 -3 -1 1 3 5 7 10 15];
%L=[-11 -9 -7 -5 -3 -1 1 3 5 7 9 11];
%L=[-6 -5 -4 -3 -2 -1  1 2 3 4 5 6];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;   cmap(7,:)=[1 1 1];
%------
varinam={'U';'V';'W'};
%plon=[118.3 122.85];  plat=[21.2 25.8];
%plon=[117.5 122.5]; plat=[20.5 25.65];
plon=[118.9 121.8];   plat=[21 24.3];
g=9.81;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   %infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_mean'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');     w.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   [nx ,ny]=size(x); nz=size(u.stag,3);
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   w.unstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
   
   for vi=wid
      if vi==3; L=L*0.1; end
      filenam=[expri,'_',varinam{vi},'_'];  
      switch (vi); case 1; vari_wind= u.unstag;  case 2; vari_wind= v.unstag;  case 3; vari_wind= w.unstag;  end 
      %---interpolation to constant-height above surface
      if isoid~=0
         P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)/g;   
         hgtiso=hgt_w; 
         variso=zeros(nx,ny);  
         for i=1:nx
          for j=1:ny
          X=squeeze(zg(i,j,:));
          Y=squeeze(vari_wind(i,j,:));     variso(i,j)=interp1(X,Y,hgtiso,'linear');
          end
         end
         plotvar=variso;
         isotype=[num2str(hgt_w/1000),'km'];
      else
         plotvar=vari_wind(:,:,lev);
         isotype=['lev',num2str(lev)];
      end  
      %%
%--plot----
    plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
    figure('position',[500 200 600 500]) 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
    cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);    
     %
    tit=[expri,'  ',varinam{vi},'  ',s_hr,minu,'z  (',type,' ',isotype,')'];  
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
    %print('-dpng',outfile,'-r400')       
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  

   end  % wid
end     % time

