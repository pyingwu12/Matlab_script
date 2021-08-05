% function b_dwdt_traj_Euler(expri)
close all
clear;  
ccc=':';
%---setting
expri='TWIN021B';  
stday=22;  sthr=22;  stmin=00;  lenm=121;
% int_xps=[55  55  55  60  60  60  65   70  70  70   75  75  80  80   95  95 95];
% int_yps=[80 100 120  90 100 110 100   90 100 110  120  80  90 110  120 100 80];
% int_zps=[ 2   2   2   2   2   2   2    2   2   2    2   2   2   2    2   2  2];

% int_xps=[70  66  63  60  70  66  63  60  70  66  63  60  70  66  63  60  70  66  63  60  70  66  63  60];
% int_yps=[90  90  90  90  92  92  92  92  94  94  94  94  96  96  96  96  98  98  98  98 100 100 100 100];
% int_zps=[ 2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2   2];

xpoints=52:2:80;
ypoints=82:2:120;

int_xps=repmat(xpoints,1,length(ypoints));
ni=0;
for i=ypoints
    ni=ni+1;
  int_yps(1,(ni-1)*length(xpoints)+1:ni*length(xpoints))=ones(1,length(xpoints))*i;
end
int_zps=ones(1,length(int_yps))*2;

% int_xps=[55  55  55  55  55  55  55   75  75  75  75  75  75  75   95  95  95  95  95  95  95];
% int_yps=[70  80  90 100 110 120 130   70  80  90 100 110 120 130   70  80  90 100 110 120 130];
% int_zps=[ 2   2   2   2   2   2   2    2   2   2   2   2   2   2    4   4   4   4   4   4   4];
% int_xps= 55 ;
% int_yps=110 ;
% int_zps=  2 ;

if length(int_zps)~=length(int_xps) || length(int_zps)~=length(int_yps) || length(int_xps)~=length(int_yps)
    error('Please check the length of int_xps etc.')
end

%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; 
%---
g=9.81;
minum=8;
dt=60;
%---
np=length(int_zps);
%---
nti=0; X=zeros(3,lenm,np); t=zeros(lenm,np);
for mi=stmin:stmin+lenm-1
  nti=nti+1;
  %---
  minu=mi;  hr=sthr+fix(minu/60);  s_date=num2str(stday+fix(hr/24),'%2.2d');
  s_hr=num2str(mod(hr,24),'%2.2d');   s_min=num2str(mod(minu,60),'%2.2d');
  %---
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  
  PH0=double(phb+ph); zg=(PH0(:,:,1:end-1)+PH0(:,:,2:end))*0.5/g;  
  ustag = ncread(infile,'U');
  vstag = ncread(infile,'V');
  wstag = ncread(infile,'W');
  u=(ustag(1:end-1,:,:)+ustag(2:end,:,:)).*0.5;
  v=(vstag(:,1:end-1,:)+vstag(:,2:end,:)).*0.5;
  w=(wstag(:,:,1:end-1)+wstag(:,:,2:end)).*0.5;
      
  if nti==1      
    dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    [nx, ny, nz]=size(zg);
    xaxis=(1:nx)*dx;    yaxis=(1:ny)*dy; 
    [yi, xi]=meshgrid(yaxis,xaxis);
    hgt = ncread(infile,'HGT');   
    xi3d=repmat(xi,1,1,nz);
    yi3d=repmat(yi,1,1,nz);
        
    for pj=1:np            
      X(1,nti,pj)=int_xps(pj)*dx;
      X(2,nti,pj)=int_yps(pj)*dy;
      X(3,nti,pj)=zg(int_xps(pj),int_yps(pj),int_zps(pj));
    end 
    %---  
  else
    for pj=1:np       
      X(:,nti,pj)=moEuler(X(:,nti-1,pj),dt,u0,v0,w0,u,v,w,xi3d,yi3d,zg0,zg,minum) ; 
      
      hgt_X2=interp2(yi,xi,hgt,X(2,nti,pj),X(1,nti,pj));
      if X(3,nti,pj)<hgt_X2; X(3,nti,pj)=hgt_X2; end
       
    end %pi    
  end %if nti==1 
  
  u0=u;  v0=v;  w0=w;  zg0=zg; 
%   if mod(nti,10)==0; disp([s_hr,s_min,' done']); end
  disp([s_hr,s_min,' done'])
end

s_stday=num2str(stday,'%.2d');  s_sthr=num2str(sthr,'%.2d');  s_stmin=num2str(stmin,'%.2d'); s_lenm=num2str(lenm,'%.2d');
save(['matfile/Trajectory/',expri,'_Euler_',s_stday,s_sthr,s_stmin,'_',s_lenm,'min_2km'],'X','int_xps','int_yps','int_zps')
