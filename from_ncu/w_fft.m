%function wind_w_fft(expri)

clear

%hr=2;   expri='e01';    fL=18; %(km)
hr=0;   expri='largens';    fL=3; %(km)
isoid=1;   % 0:model level. ~=0:constant-height. set the lev/height below
%
if isoid==0; lev=15; else hgt_w =2000; end  % level or height for plot
%---DA or forecast time---
%infilenam='wrfmean';  minu='00';  type='mean';
infilenam='wrfout';  minu='00';   type='sing';
%infilenam='output/fcstmean'; minu='00'; type=infilenam(8:11); %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';   % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/work/pwin/plot_cal/largens/',expri];
%L=[-45 -30 -15 -10 -5 -2.5    2.5 5 10 15 30 45];
%L=[-2.5 -2 -1.5 -1 -0.5 -0.25 0.25 0.5 1 1.5 2 2.5];
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1   0.1 0.2 0.3 0.4 0.5 0.6];
qscale = 0.008 ;
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='W filter';  filenam=[expri,'_w-fft_'];
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.3 121.8];   plat=[21 24.3];
g=9.81;
int=8; 

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');
%---set filename---
%   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_mean'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
   dx =netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX')/1000 ;
   dy =netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY')/1000 ;
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'W');       w.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   w.unstag=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
   [nx ny]=size(w.stag(:,:,1));
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   
   %---interpolation to constant-height above surface
   if isoid~=0
      P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)/g;   
      hgt=zeros(nx,ny);
      hgtiso=double(hgt)+hgt_w;  
      variso=zeros(nx,ny);  uiso=zeros(nx,ny);  viso=zeros(nx,ny);
      for i=1:nx
       for j=1:ny
       X=squeeze(zg(i,j,:));
       Y=squeeze(w.unstag(i,j,:));     variso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       %Y=squeeze(u.unstag(i,j,:));     u.iso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       %Y=squeeze(v.unstag(i,j,:));     v.iso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       %Y=squeeze(w.unstag(i,j,:));     variso(i,j)=interp1(X,Y,hgt_w,'linear');
       end
      end
      w.ori=variso; 
      %u.plot=u.iso(1:int:nx,1:int:ny,:);   v.plot=v.iso(1:int:nx,1:int:ny,:); 
      isotype=[num2str(hgt_w/1000),'km'];
   else
      w.ori=w.unstag(:,:,lev);
      u.plot=u.unstag(1:int:nx,1:int:ny,lev);   v.plot=v.unstag(1:int:nx,1:int:ny,lev); 
      isotype=['lev',num2str(lev)];    
   end
   %%
%---Low pass filter---
   w.fft=fft2(w.ori);   w.fft=fftshift(w.fft);  %Discrete Fourier transform      
   filnum=((dx*nx/fL)+(dy*ny/fL))*0.5; %decide the wave number 
   %
   filter=ones(nx,ny);
   for i = 1:nx
     for j =1:ny
        dist = ((i-(nx/2))^2 + (j-(ny/2))^2)^.5;
        if dist > filnum
          filter(i,j) = 0;
        end
     end
   end
   w.fil=filter.*w.fft;   %execute filter   
   w.fil = ifftshift(w.fil);
   w.fil = ifft2(w.fil);  %Inverse discrete Fourier transform
   w.fil = real(w.fil);
   %-------
   
   plotvar=w.ori;
   %xi=x(1:int:nx,1:int:ny);      yi=y(1:int:nx,1:int:ny);
%--plot----
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %%
   figure('position',[1000 200 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;   
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8); 
   %---horizontal wind vector---
%   hold on
%   windmax=15;  scale=15;
%   windbarbM_mapVer(xi,yi,u.plot,v.plot,scale,windmax,[0.05 0.02 0.5],0.8)
%   windbarbM_mapVer(plon(1)+0.2,plat(2)-0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
%   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,' L=',num2str(fL),')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype,'_',num2str(fL)];
%     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%     system(['rm ',[outfile,'.pdf']]);  
   
end     % time

