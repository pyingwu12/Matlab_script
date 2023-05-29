
% close all
clear;   ccc=':';
%---setting
expri='TWIN024B';  
stday=22;  sthr=21;  stmin=00; lenm=180;
int_xps=[85  85  85  65  65  65  75  75];
int_yps=[90 100 110  90 100 110 110 105];
int_zps=[ 3   3   3   3   3   3   3   2];
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% fignam=[expri,'_cros-theta_'];
%---
g=9.81;
minum=5;
%---
np=length(int_zps);
nti=0;  p1=zeros(1,lenm); p2=zeros(1,lenm); p3=zeros(1,lenm);
for mi=stmin:stmin+lenm-1
  nti=nti+1;
  %---
  minu=mi;
  hr=sthr+fix(minu/60);
  s_date=num2str(stday+fix(hr/24),'%2.2d');
  s_hr=num2str(mod(hr,24),'%2.2d'); 
  s_min=num2str(mod(minu,60),'%2.2d');
  %---
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
  u.stag = ncread(infile,'U');
  v.stag = ncread(infile,'V');
  w.stag = ncread(infile,'W');
  ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
  
  %---
  PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;    zg=PH/g; 
  
 
  %---
  minu0=mi-1;
  hr=sthr+fix(minu0/60);
  s_date0=num2str(stday+fix(hr/24),'%2.2d');
  s_hr0=num2str(mod(hr,24),'%2.2d'); 
  s_min0=num2str(mod(minu0,60),'%2.2d');
  infile0=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date0,'_',s_hr0,ccc,s_min0,ccc,'00'];
  u.stag0 = ncread(infile0,'U');
  v.stag0 = ncread(infile0,'V');
  w.stag0 = ncread(infile0,'W');
  %---
  
  u.tm = (u.stag0 + u.stag)*0.5 ;
  v.tm = (v.stag0 + v.stag)*0.5 ;
  w.tm = (w.stag0 + w.stag)*0.5 ;  
  
  u.unstag=(u.tm(1:end-1,:,:)+u.tm(2:end,:,:)).*0.5;
  v.unstag=(v.tm(:,1:end-1,:)+v.tm(:,2:end,:)).*0.5;
  w.unstag=(w.tm(:,:,1:end-1)+w.tm(:,:,2:end)).*0.5;
  
  %---
  if nti==1
      [nx, ny, nz]=size(zg);
      x=(1:nx)*dx;
      y=(1:ny)*dy; 
      [yi, xi]=meshgrid(y,x);
      hgt = ncread(infile,'HGT');
  end
  for pi=1:np      
    if nti==1
      p1(pi,nti)=int_xps(pi)*dx;
      p2(pi,nti)=int_yps(pi)*dy;
      p3(pi,nti)=zg(int_xps(pi),int_yps(pi),int_zps(pi));
    elseif nti==2 
      p1(pi,nti)=p1(pi,1)+u.unstag(int_xps(pi),int_yps(pi),int_zps(pi))*60;
      p2(pi,nti)=p2(pi,1)+v.unstag(int_xps(pi),int_yps(pi),int_zps(pi))*60;
      p3(pi,nti)=p3(pi,1)+w.unstag(int_xps(pi),int_yps(pi),int_zps(pi))*60;
    else
    
      dis_x= repmat(xi,1,1,nz) -p1(pi,nti-1);
      dis_y= repmat(yi,1,1,nz) -p2(pi,nti-1);
      dis_z= zg-p3(pi,nti-1);      
      dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
      [dist_min, indx]=sort(dist(:));    
      dist_w=1./dist;
    
      dist_w_temp=dist_w(indx(1:minum));
      u_temp=u.unstag(indx(1:minum));
      up=sum(u_temp.*dist_w_temp)/sum(dist_w_temp);
    
      v_temp=v.unstag(indx(1:minum));
      vp=sum(v_temp.*dist_w_temp)/sum(dist_w_temp);
    
      w_temp=w.unstag(indx(1:minum));
      wp=sum(w_temp.*dist_w_temp)/sum(dist_w_temp);    
    
      p1(pi,nti)=p1(pi,nti-1)+up*60;
      p2(pi,nti)=p2(pi,nti-1)+vp*60;
      p3(pi,nti)=p3(pi,nti-1)+wp*60;
     
    end %if
    
  end %pi
      
  if mod(mi,10)==0; disp([s_hr,s_min,' done']); end
end
%%

hf=figure('position',[100 200 800 700]);
surf(xi,yi,hgt,'linestyle','none')
hold on
for pi=1:np
 plot3(p1(pi,:),p2(pi,:),p3(pi,:),'linewidth',3)
 plot3(p1(pi,1),p2(pi,1),p3(pi,1),'xk','markersize',10,'linewidth',2)
end
xlabel('X'); ylabel('Y'); zlabel('Height')
set(gca,'fontsize',16)
