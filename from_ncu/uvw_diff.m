function uvw_diff(expri1,expri2)
%-------------------------------------------------------
% u,v,w difference(exp1-exp2) between expri1 to expri2  (DA cycle & forecasting time)
%          wid=1-U, 2-V, 3-W
%-------------------------------------------------------
%
%clear all
close all

hr=[0 2];   %expri1='e01';  expri2='e02';    figtit1='24S04';   figtit2='S1204' 
wid=[1 2];   isoid=0;   % 0:model level. ~=0:constant-height
%
if isoid==0; lev=12; else hgt_w =3500; end  % level or height for plot
%---DA or forecast time---
%infilenam='wrfout';  minu='00';   type='sing';
infilenam='output/analmean'; minu='00'; type=infilenam(8:11); %!!!!infile1

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';   % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/';
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
L=[-7 -5 -3 -2 -1 -0.5 0.5 1 2 3 5 7];
%L=[-10 -7 -5 -3 -2 -1 1 2 3 5 7 10];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
%load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br; 
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(2:14,:);
%------
varinam={'U';'V';'W'};
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
   truelat1 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT1')); 
   truelat2 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT2'));
   cen_lon =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LON'));
   
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
  % varid  =netcdf.inqVarID(ncid,'W');     w.stag =netcdf.getVar(ncid,varid);
  % varid  =netcdf.inqVarID(ncid,'PH');       ph1  =netcdf.getVar(ncid,varid);
  % varid  =netcdf.inqVarID(ncid,'PHB');      phb1 =netcdf.getVar(ncid,varid); 
  % varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   [nx ny]=size(x); nz=size(u.stag,3);
   u.unstag1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
   v.unstag1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
%   w.unstag1=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5; 
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
  % varid  =netcdf.inqVarID(ncid,'W');     w.stag =netcdf.getVar(ncid,varid);
  % varid  =netcdf.inqVarID(ncid,'PH');       ph2  =netcdf.getVar(ncid,varid);
  % varid  =netcdf.inqVarID(ncid,'PHB');      phb2 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   u.unstag2=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag2=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5; 
 %  w.unstag2=(w.stag(:,:,1:nz)+w.stag(:,:,2:nz+1)).*0.5; 
   
   for vi=wid
      if vi==3; L=L*0.1; end
      filenam=[expri1,'diff',expri2,'_',varinam{vi},'_'];  
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
         plotvar=variso1-variso2;
         isotype=[num2str(hgt_w/1000),'km'];
      else
         plotvar=vari1(:,:,lev)-vari2(:,:,lev);
         isotype=['lev',num2str(lev)];
      end
%}      
%--plot----
   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 200 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',cen_lon,'parallels',[truelat1 truelat2],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
   title(hc,'(m/s)')
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
    %
   %tit=[expri1,' minus ',expri2,'  ',varinam{vi},'  ',s_hr,minu,'z  (',type,' ',isotype,')'];
   tit=[varinam{vi},' wind difference ',figtit1,' - ',figtit2];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);    
%    
   end  % wid
end     % time

