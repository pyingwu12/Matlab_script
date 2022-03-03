%-------------------------------------------------------
% QRAIN increment (anal-fcst) after DA
%-------------------------------------------------------

clear
hr=00;   minu='00';    expri='e06';  wid=[1 2];   isoid=0;
if isoid==0; lev=5; else hgt_w =1500; end  % level or height for plot

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
L=[-16 -12 -8 -6 -4 -2 2 4 6 8 12 16].*0.1;
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam={'U';'V';'W'};
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.3 121.8];   plat=[21 24.3];
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
   varid  =netcdf.inqDimID(ncid,'south_north'); [~, ny]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'west_east'); [~, nx]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');     w.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph1  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb1 =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   [nx ny]=size(x); nz=size(u.stag,3);
   u.unstag1=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag1=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   w.unstag1=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');     w.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph2  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb2 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   u.unstag2=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag2=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
   w.unstag2=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
   for vi=wid
      if vi==3; L=L*0.1; end
      filenam=[expri,'_',varinam{vi},'-incr','_'];  
      switch (vi); case 1; vari1= u.unstag1;  vari2= u.unstag2;  case 2; vari1= v.unstag1; vari2= v.unstag2; ...
                   case 3; vari1= w.unstag1;  vari2= w.unstag2;  end 
      %---interpolation to constant-height above surface
      if isoid~=0
         P0=double(phb1+ph1);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg1=double(PH)/g;   
         P0=double(phb2+ph2);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg2=double(PH)/g;   
         hgtiso=double(hgt)+hgt_w; 
         variso1=zeros(nx,ny);  variso2=zeros(nx,ny);
         for i=1:nx
          for j=1:ny
          X=squeeze(zg1(i,j,:));
          Y=squeeze(vari1(i,j,:));     variso1(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
          X=squeeze(zg2(i,j,:));
          Y=squeeze(vari2(i,j,:));     variso2(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
          end
         end
         plotvar=variso2-variso1;
         isotype=[num2str(hgt_w/1000),'km'];
      else
         plotvar=vari2(:,:,lev)-vari1(:,:,lev);
         isotype=['lev',num2str(lev)];
      end      
%--plot----
      plotvar(plotvar==0)=NaN;
      pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
      figure('position',[500 500 600 500]) 
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
      [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
      cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
      hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
      %m_coast('color','k');
      m_gshhs_h('color','k','LineWidth',0.8);    
    %
      tit=[expri,'  ',varinam{vi},' increment  ',s_hr,minu,'z  (',isotype,')'];
      title(tit,'fontsize',15)
      outfile=[outdir,'/',filenam,s_hr,minu,'_',isotype];
      %print('-dpng',outfile,'-r400')   
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);  

   end  % wid   
end    
