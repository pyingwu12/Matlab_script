
% close all
clear;   ccc=':';
%---setting
expri='TWIN025B';  
stday=22;  sthr=21;  stmin=10;  lenm=60;
int_xps=[60  60  60  60  60  65  65  65  70  70  70   75  75 75  75   80  80   95  95 95];
int_yps=[80  90 100 110 120  90 100 110  90 100 110  120 110 90  80   90 110  120 100 80];
int_zps=[ 2   2   2   2   2   2   2   2   2   2   2    2   2  2   2   2   2    2   2   2];

% int_xps=[55  55  55  55  55  55  55   75  75  75  75  75  75  75   95  95  95  95  95  95  95];
% int_yps=[70  80  90 100 110 120 130   70  80  90 100 110 120 130   70  80  90 100 110 120 130];
% int_zps=[ 2   2   2   2   2   2   2    2   2   2   2   2   2   2    4   4   4   4   4   4   4];
% int_xps= 55 ;
% int_yps=110 ;
% int_zps=  2 ;

%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% fignam=[expri,'_cros-theta_'];
%---
g=9.81;
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
Rcp=287.43/1005; cp=1005;
Lv=(2.4418+2.43)/2 * 10^6 ;
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
  %
%    P = ncread(infile,'P')+ncread(infile,'PB'); P100=P/100; %pressure in hPa
%       theda = ncread(infile,'T')+300;   
%       temp  = theda.*(1e3./P100).^(-Rcp); %temperature (K)   
      
  if nti==1      
    dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    [nx, ny, nz]=size(zg);
    xaxis=(1:nx)*dx;    yaxis=(1:ny)*dy; 
    [yi, xi]=meshgrid(yaxis,xaxis);
    hgt = ncread(infile,'HGT');   
    xi3d=repmat(xi,1,1,nz);
    yi3d=repmat(yi,1,1,nz);
    
%     qv = ncread(infile,'QVAPOR');    
%     ev=qv./(epsilon+qv).*P100;   %partial pressure of water vapor
%     Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
    
    for pi=1:np            
      X(1,nti,pi)=int_xps(pi)*dx;
      X(2,nti,pi)=int_yps(pi)*dy;
      X(3,nti,pi)=zg(int_xps(pi),int_yps(pi),int_zps(pi));
      %
%       t_parcel(nti,pi)=temp(int_xps(pi),int_yps(pi),int_zps(pi));
%       t(nti,pi) = temp(int_xps(pi),int_yps(pi),int_zps(pi)); 
%       Td0(pi)=Td(int_xps(pi),int_yps(pi),int_zps(pi));
    end 
    u1=u;  v1=v;  w1=w;  zg0=zg; 
    %---  
  
  elseif nti==2
    u_tm=(u+u1)*0.5; v_tm=(v+v1)*0.5; w_tm=(w+w1)*0.5; 
    for pi=1:np     
      X(1,nti,pi)=X(1,nti-1,pi)+u_tm(int_xps(pi),int_yps(pi),int_zps(pi))*dt;
      X(2,nti,pi)=X(2,nti-1,pi)+v_tm(int_xps(pi),int_yps(pi),int_zps(pi))*dt;  
      X(3,nti,pi)=X(3,nti-1,pi)+w_tm(int_xps(pi),int_yps(pi),int_zps(pi))*dt; 
      %---
%       t_parcel(nti,pi)=t_parcel(nti-1,pi) - g/cp * (X(3,nti,pi)-X(3,nti-1,pi)); 
%       %---
%       dis_x= xi3d-X(1,nti,pi);  dis_y= yi3d-X(2,nti,pi);  dis_z= zg-X(3,nti,pi);  
%       dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
%       [~, indx]=sort(dist(:));     dist_w=1./dist; 
%         dist_w_temp=dist_w(indx(1:minum));      
%         t_temp=temp(indx(1:minum));   
%         %---inverse distance weighted mean---
%         t(nti,pi)=sum(t_temp.*dist_w_temp)/sum(dist_w_temp);   
    end
    u0=u1;  v0=v1;  w0=w1;   u1=u;  v1=v;  w1=w;  zg1=zg;
  else
    for pi=1:np                    
%       X(:,nti,pi)=RK4(X(:,nti-2,pi),dt,u0,v0,w0,u1,v1,w1,u,v,w,xi3d,yi3d,zg0,zg1,zg,minum) ;   
      X(:,nti,pi)=RK3(X(:,nti-2,pi),dt,u0,v0,w0,u1,v1,w1,u,v,w,xi3d,yi3d,zg0,zg1,zg,minum) ; 
%       X(:,nti,pi)=RK2(X(:,nti-2,pi),dt,u0,v0,w0,u1,v1,w1,xi3d,yi3d,zg0,zg1,minum) ;   
%       %---
%       t_parcel(nti,pi)=t_parcel(nti-1,pi) - g/cp * (X(3,nti,pi)-X(3,nti-1,pi));
%       %---
%       dis_x= xi3d-X(1,nti,pi);  dis_y= yi3d-X(2,nti,pi);  dis_z= zg-X(3,nti,pi);  
%       dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
%       [~, indx]=sort(dist(:));     dist_w=1./dist;       
%       dist_w_temp=dist_w(indx(1:minum));      
%         t_temp=temp(indx(1:minum));   
%         %---inverse distance weighted mean---
%         t(nti,pi)=sum(t_temp.*dist_w_temp)/sum(dist_w_temp);
      hgt_X2=interp2(yi,xi,hgt,X(2,nti,pi),X(1,nti,pi));
      if X(3,nti,pi)<hgt_X2; X(3,nti,pi)=hgt_X2; end
       
    end %pi    
    u0=u1;  v0=v1;  w0=w1;  zg0=zg1;
    u1=u;   v1=v;   w1=w;  zg1=zg;
  end %if nti==1 
 
%   if mod(nti,10)==0; disp([s_hr,s_min,' done']); end
  disp([s_hr,s_min,' done'])
end

s_stday=num2str(stday,'%.2d');  s_sthr=num2str(sthr,'%.2d');  s_stmin=num2str(stmin,'%.2d'); s_lenm=num2str(lenm,'%.2d');
% save(['matfile/Trajectory/',expri,'_RK2_',s_stday,s_sthr,s_stmin,'_',s_lenm,'min'],'X')
%%
%
hgt(hgt+1<=1)=NaN;
hf=figure('position',[100 200 800 700]);
surf(xi,yi,hgt,'linestyle','none')
hold on
for pi=1:np
 plot3(X(1,:,pi),X(2,:,pi),X(3,:,pi),'linewidth',3)
 plot3(X(1,1,pi),X(2,1,pi),X(3,1,pi),'xk','markersize',10,'linewidth',2)
end 
xlabel('X'); ylabel('Y'); zlabel('Height')
set(gca,'fontsize',16)
%}
%%
% hf=figure('position',[100 200 800 700]);
% plot(t); hold on
% plot(t_parcel)
% %}