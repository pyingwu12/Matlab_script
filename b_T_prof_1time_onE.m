% close all
clear;   ccc=':';
%---setting
expri='TWIN003B';  s_date='22'; hr=22; minu=00;  lev=1;
xp=156;yp=91;
%----
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='Non-dimensional mountain height';   fignam=[expri,'_FrH_'];

%---
g=9.81;
zgi=10:10:25000;    ytick=500:1000:zgi(end); 
Rcp=287.43/1005; %Rsd=287.43; 
cpd=1005;
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
Lv=(2.4418+2.43)/2 * 10^6 ;
 A=1.26e-3;  % K^-1
 B=5.14e-4;  % K^-1


for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');   t=t+300;   
    qv = ncread(infile,'QVAPOR');  qv=double(qv);   
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    p = ncread(infile,'P');   pb = ncread(infile,'PB'); 
    hgt = ncread(infile,'HGT');
    %----   
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;      
    [nx, ny, nz]=size(t);
    [y, x]=meshgrid(1:ny,1:nx);
    
 
%     N2=g./t(:,:,lev).* (t(:,:,lev+1)-t(:,:,lev))./zg(:,:,lev+1)-zg(:,:,lev);
%     Hhat=N2*max(max(hgt))^2./spd(:,:,lev).^2;
        
    X=squeeze(zg(xp,yp,:));   Y=squeeze(t(xp,yp,:));   
    t_h=interp1(X,Y,zgi,'linear');
    
    
    %---LCL---
    P=p+pb;
    T=t.*(1e5./P).^(-Rcp); %temperature
    hP=P/100; %pressure in hap
    ev=qv./epsilon.*hP;   %partial pressure of water vapor
    Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
    Zlcl=( zg(:,:,1)*1e-3+(T(:,:,1)-Td(:,:,1))/8 )*1e3;  
    
    %---theta e----
   Tlcl=(1-A.*Td)./(1./Td+B.*log(T./Td)-A);    
   the=T.*exp(Lv.*qv./(cpd.*Tlcl));
    
   
   Y=squeeze(the(xp,yp,:));   
   thetaE_h=interp1(X,Y,zgi,'linear');

    
    %---plot---
    hf=figure('position',[100 50 680 900]);  
    plot(t_h,zgi); hold on
    
       line([303 313],[Zlcl(xp,yp) Zlcl(xp,yp)])

       plot(thetaE_h,zgi)
%     [c, hp]=contourf(plotvar,20,'linestyle','none');
%     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8);  
%     %
%     set(gca,'fontsize',16,'LineWidth',1.2) 
%     set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
%     xlabel('(km)'); ylabel('(km)');
%     tit={expri,[titnam,'  ',s_hr,s_min,' UTC']}; 
%     title(tit,'fontsize',18)
% 

%    
%     outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
%     print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    

  end
end