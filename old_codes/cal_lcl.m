% close all
clear;   ccc=':';
%---setting
expri='TWIN003B';  s_date='22'; hr=21; minu=00;  h_int=100;
%
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
cpd=1005;
Rsd=287.43;
Rcp=Rsd/cpd; 
g=9.81;
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
 
toph=25; %km
lev=1;

Lv=(2.4418+2.43)/2 * 10^6 ;

for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');        t=t+300;  % potential temp.
    qv = ncread(infile,'QVAPOR');  qv=double(qv);   
    ph = ncread(infile,'PH');   phb = ncread(infile,'PHB');
    p = ncread(infile,'P');     pb = ncread(infile,'PB');    
    %---
    
    P  = p+pb; %pressure (pa)
    hP = P/100; %pressure in hap
    PH0= phb+ph;    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
    zg = PH/g;  %height (m)
    T  = t.*(1e5./P).^(-Rcp); %temperature (K)
    
    [nx ,ny, ~]=size(T);

    %---LCL---
    lapse_d=g/cpd; % (K/m)
    
    
    zlcl=zeros(nx,ny);
    for hi=1:3 %toph*1e3
      t2 = T(:,:,lev)-lapse_d;  
      esw2 = 6.11*exp(19.8-5417./t2);          
    end
    
%     ev=qv./epsilon.*hP;   %partial pressure of water vapor
%     Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
%     Zlcl=( zg(:,:,1)*1e-3+(T(:,:,1)-Td(:,:,1))/8 )*1e3;
%     
%     %---
%     Tlcl=2840/(3.5*log(T)-log(ev)-4.805)+55;   
%     lapsew= g .* (Rsd*T.^2 + Lv*qv.*T ) ./ (cpd*Rsd*T.^2 + Lv^2.*qv*epsilon); 
    
   

  end
end