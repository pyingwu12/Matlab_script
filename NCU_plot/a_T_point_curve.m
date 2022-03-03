%--------------------------------------------------
% Q increment (anal-fcst) profile 
%--------------------------------------------------

%clear

hr=2;   minu='00';    expri='e04';  px=100; py=110; 

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
varinam='Theta_e diff.';   filenam=[expri,'_The-vtcl-diff_'];

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
   varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
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
   %
   T0=T.*(100000./P).^(-R/cp); %temperature
   thes=T.*exp(Lc.*qv./(cp.*T0));

   area=1;
   themean=mean(mean(the(px-area:px+area,py-area:py+area,:),1),2);
   Tmean=mean(mean(T(px-area:px+area,py-area:py+area,:),1),2);
   thesmean=mean(mean(thes(px-area:px+area,py-area:py+area,:),1),2);
   
   %---plot
   figure('position',[500 500 600 500]) 
   plot(squeeze(themean),1:nz,'LineWidth',2); hold on
   plot(squeeze(Tmean),1:nz,'LineWidth',2,'color','k');
   plot(squeeze(thesmean),1:nz,'LineWidth',2,'LineStyle','--');
   
   %legh=legend('256 w/o da','40 w/o da','256 w/ da','40 w/ da'); 
   %set(legh,'fontsize',13,'Location','Southeast','box','off')

   %
   set(gca,'YLim',[1 30],'fontsize',13,'LineWidth',1)
   xlabel('K','fontsize',14);  ylabel('height(km)','fontsize',14);
   % 
   
   %---plot---      
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z (',type,')'];  
   title(tit,'fontsize',15,'Interpreter','none')
   %outfile=[outdir,'/',filenam,s_hr,minu,'_',type];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);   
end   