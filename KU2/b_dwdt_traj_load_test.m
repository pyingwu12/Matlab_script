%
clear;   ccc=':';
%---setting
expri='TWIN025B';  
stday=22;  sthr=21;  stmin=00;  lenm=181;

%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% fignam=[expri,'_cros-theta_'];
%---
s_stday=num2str(stday,'%.2d');  s_sthr=num2str(sthr,'%.2d');  s_stmin=num2str(stmin,'%.2d'); s_lenm=num2str(lenm,'%.2d');
load(['matfile/Trajectory/',expri,'_Euler_',s_stday,s_sthr,s_stmin,'_',s_lenm,'min_2km'])
% X_smo=(X(:,1:end-4,:)+X(:,2:end-3,:)+X(:,3:end-2,:)+X(:,4:end-1,:)+X(:,5:end,:))/5;
%---
g=9.81;
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
Rcp=287.43/1005; cpd=1005; 
Rd=287.43;
Lv=(2.4418+2.43)/2 * 10^6 ;
num=8;
dt=60;
%---
np=size(X,3);
% calpoint=[103 104 105 106];
% np=length(calpoint);
%---
 mi=stmin;
   minu=mi;  hr=sthr+fix(minu/60);  s_date=num2str(stday+fix(hr/24),'%2.2d');
  s_hr=num2str(mod(hr,24),'%2.2d');   s_min=num2str(mod(minu,60),'%2.2d');
  %---
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
   theta = ncread(infile,'T')+300;   
    dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    [nx, ny, nz]=size(theta);
    xaxis=(1:nx)*dx;    yaxis=(1:ny)*dy; 
    [yi, xi]=meshgrid(yaxis,xaxis);
    hgt = ncread(infile,'HGT');   

%%
nti=0; 
% for mi=stmin:stmin+lenm-1
for mi=stmin:stmin+3
    tic
  nti=nti+1;
  %---
  minu=mi;  hr=sthr+fix(minu/60);  s_date=num2str(stday+fix(hr/24),'%2.2d');
  s_hr=num2str(mod(hr,24),'%2.2d');   s_min=num2str(mod(minu,60),'%2.2d');
  %---
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  PH0=ncread(infile,'PH')+ncread(infile,'PHB'); zg=(PH0(:,:,1:end-1)+PH0(:,:,2:end))*0.5/g;  
  wstag = ncread(infile,'W');
  w=(wstag(:,:,1:end-1)+wstag(:,:,2:end)).*0.5;
  %
  PB=ncread(infile,'PB');  P = ncread(infile,'P')+PB; P100=P/100; %pressure in hPa
  theta = ncread(infile,'T')+300;  
  
  temperature  = theta.*(1e3./P100).^(-Rcp); %temperature (K) 
      
  if nti==1      
    dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    [nx, ny, nz]=size(theta);
    xaxis=(1:nx)*dx;    yaxis=(1:ny)*dy; 
    [yi, xi]=meshgrid(yaxis,xaxis);
    hgt = ncread(infile,'HGT');   
    xi3d=repmat(xi,1,1,nz);
    yi3d=repmat(yi,1,1,nz);
  end %if nti==1 
  
  npi=0;
  for pj=1:15
    npi=npi+1;  
    dis_x= xi3d-X(1,nti,pj);  dis_y= yi3d-X(2,nti,pj);  dis_z= zg-X(3,nti,pj);  
    dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
    [~, indx]=sort(dist(:)); 
    if nti==1  
      w_traj(nti,npi)=w(indx(1));
      t_traj(nti,npi)=temperature(indx(1));
    else 
      dist_w=1./dist;
      dist_w_temp=dist_w(indx(1:num));   
      %
      vari_temp=w(indx(1:num));        
      w_traj(nti,npi)=sum(vari_temp.*dist_w_temp)/sum(dist_w_temp);  %---inverse distance weighted mean---   
      
       vari_temp=temperature(indx(1:num));        
      t_traj(nti,npi)=sum(vari_temp.*dist_w_temp)/sum(dist_w_temp);  %---inverse distance weighted mean---      

    end
  end
  toc
%   if mod(nti,5)==0
  disp([s_hr,s_min,' done'])
%   end
end

%%
%
hgt(hgt+1==1)=NaN;
hf=figure('position',[100 200 985 755]);
surf(xi,yi,hgt,'linestyle','none')
cmp = getPyPlot_cMap('BuGn');
colormap(cmp)
hc=colorbar;
title(hc,'m')

% fin=find(X(3,end,:)>1000);
%
hold on
% for pp=1:length(fin)
%    pj=fin(pp);
for pj=1:size(X,3)
 plot3(X(1,:,pj),X(2,:,pj),X(3,:,pj),'linewidth',3)
 plot3(X(1,1,pj),X(2,1,pj),X(3,1,pj),'xk','markersize',5,'linewidth',2)
end 
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Height (m)')
set(gca,'fontsize',16,'Xlim',[0 200000],'Ylim',[0 210000],'Zlim',[0 2500])
title(expri)
%
% outfile=[outdir,'/',expri,'_dwdt-trajectary_2km'];
%    print(hf,'-dpng',[outfile,'.png'])    
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
%%
%{
col=winter(np);
hf=figure('position',[100 60 1200 900]);
subplot(3,1,1)
for i=1:np
plot(squeeze(X(1,:,i)),'linewidth',2,'color',col(i,:)); hold on
end

subplot(3,1,2)
for i=1:np
plot(squeeze(X(2,:,i)),'linewidth',2,'color',col(i,:)); hold on
end

subplot(3,1,3)
for i=1:np
plot(squeeze(X(3,:,i)),'linewidth',2,'color',col(i,:)); hold on
end
%}
%%
%{
hf=figure('position',[100 200 1200 700]);
ax1=subplot(3,1,1);
% plot(t_Euler(:,3),'linewidth',3)
% hold on
% plot(t_parcel(:,3),'linestyle','--','linewidth',3)
% set(gca,'xlim',[0 182])

subplot(3,1,2)
set(gca,'xlim',[0 182])
% plot(B_Euler(:,3),'linewidth',3)
hold on
plot((w_Euler(2:end,1)-w_Euler(1:end-1,1))/dt,'linewidth',3)
% line([1 size(B_Euler,1)],[0 0],'color','k')

subplot(3,1,3)
% plot(squeeze(X(3,:,[ 13])),'linewidth',3)
plot(squeeze(X(3,:,5)),'linewidth',3)
set(gca,'xlim',[0 182])


outfile=[outdir,'/',expri,'_dwdt-trajectary'];
%  print(hf,'-dpng',[outfile,'.png'])    
%  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}