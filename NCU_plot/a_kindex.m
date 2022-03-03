
clear

hr=2;   minu='00';    expri='e01';   
lev1=900; lev2=1000;
%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/fcstmean';  type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br4.mat';  cmap=colormap_br4;  
%------
varinam='theta diff.';   filenam=[expri,'_Th-vtcl-diff_'];
pai=[1000:-25:900,850:-50:700 500 200 100 50];    
plon=[118.3 122.85];  plat=[21.2 25.8];
%---coeffitions--
 cp=1005;  % J/(K*kg)
 Lat=2430; % J/g
 Lc=2.5e6; % J/Kg
 R=287.43;
 eps=0.622; % esp=Rd/Rv=Mv/Md
 A=1.26e-3;  % K^-1
 B=5.14e-4;  % K^-1
 
%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'T');        t   =netcdf.getVar(ncid,varid);  T=t+300;
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'P');       p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   
   P=p+pb;    
   ev=qv./eps.*P;   %partial pressure of water vapor
   Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor
   Tlcl=(1-A.*Td)./(1./Td+B.*log(T./Td)-A);    
   the=T.*exp(Lc.*qv./(cp.*Tlcl));
   T0=T.*(100000./P).^(R/cp);

      zp=P/100;  [nx ny nz]=size(the);
   tic
   for i=1:nx
    for j=1:ny
    X=squeeze(zp(i,j,:));
    Y=squeeze(T0(i,j,:));     t_iso(i,j,:)=interp1(X,Y,pai,'linear');
    Y=squeeze(Td(i,j,:));     td_iso(i,j,:)=interp1(X,Y,pai,'linear');
    end
   end      
   toc
   %%
   lev1=900; lev2=1000;
   diff=t_iso(:,:,pai==lev1)-t_iso(:,:,pai==lev2);
   Kidx=t_iso(:,:,pai==850)-t_iso(:,:,pai==500)+td_iso(:,:,pai==850)-(t_iso(:,:,pai==700)-td_iso(:,:,pai==700));
   %---plot---      
   plotvar=Kidx-273;
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   %
   figure('position',[600 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c1 hp]=m_contourf(x,y,plotvar);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   %m_gshhs_h('color','k','LineWidth',0.8);
   %cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
   %hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1);   title(hc,'(K)','fontsize',12)
   colorbar
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z (',type,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);   
end    

