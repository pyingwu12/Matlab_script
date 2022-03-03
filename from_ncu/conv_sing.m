%function conv_sing(hr,minu,expri)
%-------------------------------------------------------
% Plot convergence
%-------------------------------------------------------
%
clear all
close all

hr=2:3; minu='00';  expri='e10';  figtit='S1204';
isoid=0;  wid=0;  int=5;  runid=1; %no running mean if =0
%
if isoid==0;   lev=12;   else    hgt_w =1000;    end  % level or height for plot
% DA or forecast time---
infilenam='wrfout';   type='sing';
%infilenam='output/fcstmean'; minu='30'; type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';     % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];       % path of the experiments
%indir=['/SAS009/pwin/expri_cctmorakot/',expri];
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];   % path of the figure output
L=[-7 -4 -1 1 4 7 ];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br([3 4 6 7 8 9 10],:); 
%---
varinam='Convergence';  filenam=[expri,'_conv__'];  
if runid~=0; filenam=['run_',filenam]; end
if wid~=0; filenam=['wid_',filenam]; end
plon=[118.9 121.8];  plat=[21 24.3];
g=9.81;   

%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');        u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');        v.stag =netcdf.getVar(ncid,varid);
%   ivarid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
%   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
%   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid);  
   varid  =netcdf.inqDimID(ncid,'west_east');   [~, nx]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'south_north'); [~, ny]=netcdf.inqDim(ncid,varid);
   dx =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX')); 
   dy =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY'));
   netcdf.close(ncid)
   u.unstag=(u.stag(2:end,:,:)-u.stag(1:end-1,:,:))./dx;
   v.unstag=(v.stag(:,2:end,:)-v.stag(:,1:end-1,:))./dy; 
   conv=u.unstag+v.unstag;
   % 
   if wid==1
   uwind=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   vwind=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
   end
   %---interpolation to constant-height above surface when isoid~=0
   if isoid~=0
      P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;      zg=double(PH)/g;   
      hgtiso=double(hgt)+hgt_w; 
      variso=zeros(nx,ny);
      for i=1:nx
       for j=1:ny
       X=squeeze(zg(i,j,:));
       Y=squeeze(conv(i,j,:));    variso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');      
       end
      end      
      plotvar=variso*-10^4;
      isotype=[num2str(hgt_w/1000),'km'];
   else
      vari=conv(:,:,lev)*-10^4;
      if runid~=0;
        plotvar=zeros(nx-2,ny-2);
        for i=2:nx-1
          for j=2:ny-1
            plotvar(i-1,j-1)=mean(mean(vari(i-1:i+1,j-1:j+1)));
          end
        end
        x=x(2:end-1,2:end-1); y=y(2:end-1,2:end-1);
      else 
        plotvar=vari;
      end
      if wid==1;   uplot=uwind(1:int:nx,1:int:ny,lev);   vplot=vwind(1:int:nx,1:int:ny,lev); end
      isotype=['lev',num2str(lev)];
   end   
   %---plot---      
   %
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %---speed shaded---   
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
   cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)   
   %title(hc,'x10^-^4','fontsize',14)
   %
   if wid==1
   hold on
   xi=x(1:int:nx,1:int:ny);        yi=y(1:int:nx,1:int:ny);
   windmax=15;  scale=15;
   windbarbM_mapVer(xi,yi,uplot,vplot,scale,windmax,[0.15 0.2 0.25],0.6)
   windbarbM_mapVer(plon(1)+0.21,plat(2)-0.2,windmax,0,25,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',13)
   end 
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:40);
 %  m_coast('color','k','LineWidth',0.8);
    m_gshhs_h('color','k','LineWidth',0.8);
   % 
   %tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,')'];  
   tit=[figtit,'  ',varinam,'  ',s_hr,minu,' UTC'];  
   %title(tit,'fontsize',15)
   %tit=figtit;
   title(tit,'fontsize',17,'Position',[-0.01 0.0287])  
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
   %
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);     
%}
end  %ti
