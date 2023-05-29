function PowSpe=cal_spectr(infile1,infile2,lev)

% type: power spectra of based state or difference ('based', 'diff', or 'both')


cp=1004.9;
R=287.04;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;

%---read infile 2, based state---     
u.stag = ncread(infile2,'U');    
v.stag = ncread(infile2,'V');   
w.stag = ncread(infile2,'W');
th.f=ncread(infile2,'T')+300;  
qv.f=ncread(infile2,'QVAPOR');
psfc.f2 = ncread(infile2,'PSFC')/100; 
 
u.f2=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
v.f2=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
w.f2=(w.stag(:,:,lev)+w.stag(:,:,lev+1)).*0.5;   
th.f2=th.f(:,:,lev);
qv.f2=double(qv.f(:,:,lev));  
%
p.p=ncread(infile2,'P');  p.b = ncread(infile2,'PB');  p.f2=(p.p(:,:,lev)+p.b(:,:,lev))/100;
t.f2=th.f2.*(1e3./p.f2).^(-R/cp);   

%---calculate 1-D wavenumber(nk2)---
[nx, ny, nzi]=size(qv.f2);    
%
cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2);    % position of mean value after shfit
[xii, yii]=meshgrid((1:ny)-ceny,(1:nx)-cenx);   
nk = (xii.^2+yii.^2 ).^0.5;                   % distant to the center
nk2=round(nk);       

%---read infile 1, perturbed state---
u.stag = ncread(infile1,'U');   
v.stag = ncread(infile1,'V'); 
w.stag = ncread(infile1,'W');
th.f=ncread(infile1,'T')+300;  
qv.f=ncread(infile1,'QVAPOR'); 
psfc.f1 = ncread(infile1,'PSFC')/100; 
%
u.f1=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
v.f1=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
w.f1=(w.stag(:,:,lev)+w.stag(:,:,lev+1)).*0.5;      
th.f1=th.f(:,:,lev);
qv.f1=double(qv.f(:,:,lev));   
%
p.p=ncread(infile1,'P');  p.b = ncread(infile1,'PB');  p.f1=(p.p(:,:,lev)+p.b(:,:,lev))/100;  
t.f1=th.f1.*(1e3./p.f1).^(-R/cp);    

   
%---difference between f1 and f2----
u.diff=u.f1-u.f2; 
v.diff=v.f1-v.f2;
w.diff=w.f1-w.f2;
t.diff=t.f1-t.f2;    
qv.diff=qv.f1-qv.f2;
psfc.diff=psfc.f1-psfc.f2;        
 
%---ffft of psfc
psfc.fft=fft2(psfc.f2);
psfc.difft=fft2(psfc.diff);
%----fft for each level 
for li=1:nzi      
    
  %--- based state---
  u.fft=fft2(u.f2(:,:,li));   
  v.fft=fft2(v.f2(:,:,li));
  w.fft=fft2(w.f2(:,:,li));
  t.fft=fft2(t.f2(:,:,li));
  qv.fft=fft2(qv.f2(:,:,li));     
  %--- 
  KE.A(:,:,li) = (abs(u.fft).^2 + abs(v.fft).^2 +  abs(w.fft).^2  )/nx/ny ;     
  UE.A(:,:,li) = (abs(u.fft).^2  )/nx/ny ;     
  VE.A(:,:,li) = (abs(v.fft).^2  )/nx/ny ;     
  WE.A(:,:,li) = (abs(w.fft).^2  )/nx/ny ;     
  SH.A(:,:,li) = ( cp/Tr*abs(t.fft).^2  )/nx/ny ;    
  LH.A(:,:,li) = ( Lv^2/cp/Tr*abs(qv.fft).^2 )/nx/ny ;      
  
  MTE.A(:,:,li) = (abs(u.fft).^2 + abs(v.fft).^2 + cp/Tr*abs(t.fft).^2 +Lv^2/cp/Tr*abs(qv.fft).^2 + R*Tr*abs(psfc.fft/Pr).^2)/nx/ny ;          
  CMTE.A(:,:,li) = (abs(u.fft).^2 + abs(v.fft).^2 + abs(w.fft).^2 + cp/Tr*abs(t.fft).^2 +Lv^2/cp/Tr*abs(qv.fft).^2 + R*Tr*abs(psfc.fft/Pr).^2)/nx/ny ;          
 
  %-----difference--------  
  u.difft=fft2(u.diff(:,:,li));   
  v.difft=fft2(v.diff(:,:,li));  
  w.difft=fft2(w.diff(:,:,li));  
  t.difft=fft2(t.diff(:,:,li));
  qv.difft=fft2(qv.diff(:,:,li));    
  %---
  diffKE.A(:,:,li) = (abs(u.difft).^2 + abs(v.difft).^2 +  abs(w.difft).^2  )/nx/ny ;     
  diffUE.A(:,:,li) = (abs(u.difft).^2  )/nx/ny ;     
  diffVE.A(:,:,li) = (abs(v.difft).^2  )/nx/ny ;     
  diffWE.A(:,:,li) = (abs(w.difft).^2  )/nx/ny ;     
  diffSH.A(:,:,li) = ( cp/Tr*abs(t.difft).^2  )/nx/ny ;    
  diffLH.A(:,:,li) = ( Lv^2/cp/Tr*abs(qv.difft).^2 )/nx/ny ;  
  
  MDTE.A(:,:,li) = (abs(u.difft).^2 + abs(v.difft).^2 + cp/Tr*abs(t.difft).^2 +Lv^2/cp/Tr*abs(qv.difft).^2 + R*Tr*abs(psfc.difft/Pr).^2)/nx/ny ;          
  CMDTE.A(:,:,li) = (abs(u.difft).^2 + abs(v.difft).^2 + abs(w.difft).^2 + cp/Tr*abs(t.difft).^2 +Lv^2/cp/Tr*abs(qv.difft).^2 + R*Tr*abs(psfc.difft/Pr).^2)/nx/ny ;          
  
end        
   
%---vertival mean of fft, and shift at the same time---
MTE.m=fftshift(mean(MTE.A,3));  
CMTE.m=fftshift(mean(CMTE.A,3));  
KE.m=fftshift(mean(KE.A,3));   
UE.m=fftshift(mean(UE.A,3));   
VE.m=fftshift(mean(VE.A,3));   
WE.m=fftshift(mean(WE.A,3));   
SH.m=fftshift(mean(SH.A,3));   
LH.m=fftshift(mean(LH.A,3));
%----
MDTE.m=fftshift(mean(MDTE.A,3));  
CMDTE.m=fftshift(mean(CMDTE.A,3));  
diffKE.m=fftshift(mean(diffKE.A,3));   
diffUE.m=fftshift(mean(diffUE.A,3));   
diffVE.m=fftshift(mean(diffVE.A,3));   
diffWE.m=fftshift(mean(diffWE.A,3));   
diffSH.m=fftshift(mean(diffSH.A,3));   
diffLH.m=fftshift(mean(diffLH.A,3));  

 
for ki=1:max(max(nk2))   
    PowSpe.MTE(ki)=sum(MTE.m(nk2==ki));
    PowSpe.CMTE(ki)=sum(CMTE.m(nk2==ki));
  PowSpe.KE(ki)=sum(KE.m(nk2==ki));
  PowSpe.UE(ki)=sum(UE.m(nk2==ki));
  PowSpe.VE(ki)=sum(VE.m(nk2==ki));
  PowSpe.WE(ki)=sum(WE.m(nk2==ki));
  PowSpe.SH(ki)=sum(SH.m(nk2==ki));
  PowSpe.LH(ki)=sum(LH.m(nk2==ki)); 
  %---
   PowSpe.MDTE(ki)=sum(MDTE.m(nk2==ki));
   PowSpe.CMDTE(ki)=sum(CMDTE.m(nk2==ki));
  PowSpe.diffKE(ki)=sum(diffKE.m(nk2==ki));
  PowSpe.diffUE(ki)=sum(diffUE.m(nk2==ki));
  PowSpe.diffVE(ki)=sum(diffVE.m(nk2==ki));
  PowSpe.diffWE(ki)=sum(diffWE.m(nk2==ki));
  PowSpe.diffSH(ki)=sum(diffSH.m(nk2==ki));
  PowSpe.diffLH(ki)=sum(diffLH.m(nk2==ki));
end
 

