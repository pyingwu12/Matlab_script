%function Qv_conv_sing(hr,expri)
%-------------------------------------------------------
% Caculate TPW of a single run (DA cycle & forecasting time & ensemble mean), 
%       plot wind on a constant-height (hgt_w) above surface when wid~=0
%-------------------------------------------------------

clear all
close all

hr=2:4;   minu='00';   expri='e10'; 
isoid=0;  wid=1;  int=5;  runid=1; %no running mean if =0

%
if isoid==0; lev=12; else hgt_w =3500; end  % level or height for plot
%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/fcstmean';  type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS007/pwin/expri_largens/WRF_shao'];  outdir='/SAS011/pwin/201work/plot_cal/largens';
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[-1 -0.5 -0.1 0.1 0.5 1];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
%load '/work/pwin/data/colormap_br4.mat';  cmap=colormap_br4; 
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br([3 4 6 7 8 9 10],:);
%---
varinam=['Qv convergence'];  filenam=[expri,'_qv-conv_'];
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];  plat=[21 24.3];
g=9.81;   
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   dx =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX')); 
   dy =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY'));
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');      qv  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid); 
   %varid  =netcdf.inqVarID(ncid,'PH');    ph =netcdf.getVar(ncid,varid);
   %varid  =netcdf.inqVarID(ncid,'PHB');   phb =netcdf.getVar(ncid,varid); 
    netcdf.close(ncid)
   u.unstag=(u.stag(2:end,:,:)-u.stag(1:end-1,:,:))/dx;
   v.unstag=(v.stag(:,2:end,:)-v.stag(:,1:end-1,:))/dy; 
   qconv= - qv*1000.*(u.unstag+v.unstag)*100;  
   if wid==1
    u.qv=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5.*qv;
    v.qv=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5.*qv;
   end

%---read wind varaibles---------------
   if isoid~=0
     P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
     zg=double(PH)/g;   
   %---interpolation to constant-height above surface
     hgtiso=double(hgt)+hgt_w;  
     for i=1:nx
       for j=1:ny
       X=squeeze(zg(i,j,:));
       Y=squeeze(qconv(i,j,:));     variso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       end
     end
     plotvar=variso; 
     isotype=[num2str(hgt_w/1000),'km'];
   else
     vari=qconv(:,:,lev); 
     if runid~=0;
        [nx ny]=size(x);
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
%      plotvar=qconv(:,:,lev);
      if wid==1;   u.plot=u.qv(1:int:nx,1:int:ny,lev);   v.plot=v.qv(1:int:nx,1:int:ny,lev); end
      isotype=['lev',num2str(lev)];  
   end
   
%---plot---
   %plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 200 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;   
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   
   xlabel(hc,'(10^-^2gKg^-^1s^-^1)','fontsize',11)
   %
   if wid==1
   hold on
   xi=x(1:int:end,1:int:end);        yi=y(1:int:end,1:int:end);
%   windmax=0.2;  scale=15;
%   windbarbM_mapVer(xi,yi,u.plot,v.plot,scale,windmax,[0.15 0.2 0.25],0.6)
%   windbarbM_mapVer(plon(1)+0.21,plat(2)-0.2,windmax,0,25,windmax,[0.8 0.05 0.1],1)
%   m_text(plon(1)+0.21,plat(2)-0.2,[num2str(windmax),' Kg/Kg*m/s'],'color',[0.8 0.05 0.1],'fontsize',13)
   qscale=0.7;  wtxt=0.3;
   h1 = m_quiver(xi,yi,u.plot,v.plot,0,'color',[0.3 0.2 0.35]) ; % the '0' turns off auto-scaling
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2);
 
   h1 = m_quiver(plon(1)+0.1,plat(2)-0.2,wtxt,0,0,'color',[0.8 0.02 0.1]) ; % the '0' turns off auto-scaling
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.3,'MaxHeadSize',300);
   set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on')
   m_text(plon(1)+0.1,plat(2)-0.32,[num2str(wtxt),' Kg/Kg*m/s'],'color',[0.8 0.02 0.1],'fontsize',12)

   end 
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
    %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
   %print('-dpng',outfile,'-r400')       
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  

end  %ti
