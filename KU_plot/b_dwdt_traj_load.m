%
clear;   ccc=':';
%---setting
expri='TWIN024';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
 
stday=22;  sthr=21;  stmin=00;  lenm=181;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% fignam=[expri,'_cros-theta_'];
%---
s_stday=num2str(stday,'%.2d');  s_sthr=num2str(sthr,'%.2d');  s_stmin=num2str(stmin,'%.2d'); s_lenm=num2str(lenm,'%.2d');
load(['matfile/Trajectory/',expri,'B_Euler_',s_stday,s_sthr,s_stmin,'_',s_lenm,'min_2km'])
%---
g=9.81;
epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
Rcp=287.43/1005; cpd=1005; 
Rd=287.43;
Lv=(2.4418+2.43)/2 * 10^6 ;
num=8;
dt=60;
%---
[~, b]=sort(squeeze(X(3,end,:)),'descend');
calpoint=b(1:6)';
np=length(calpoint); 

%%
nti=0; 
for mi=stmin:stmin+lenm-1
% for mi=stmin:stmin+3
  nti=nti+1;
  %---
  minu=mi;  hr=sthr+fix(minu/60);  s_date=num2str(stday+fix(hr/24),'%2.2d');
  s_hr=num2str(mod(hr,24),'%2.2d');   s_min=num2str(mod(minu,60),'%2.2d');
  %---infile 1---
  infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  wstag = ncread(infile1,'W');
  w1=(wstag(:,:,1:end-1)+wstag(:,:,2:end)).*0.5;
  qv1 = ncread(infile1,'QVAPOR');  
    qr = double(ncread(infile1,'QRAIN'));   
    qc = double(ncread(infile1,'QCLOUD'));
    qg = double(ncread(infile1,'QGRAUP'));  
    qs = double(ncread(infile1,'QSNOW'));
    qi = double(ncread(infile1,'QICE'));  
  hyd1=qr+qc+qg+qs+qi;

  %---infile 2---
  infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  %---   
  PH0=ncread(infile2,'PH')+ncread(infile2,'PHB'); 
  P_p=ncread(infile2,'P');  
  P = ncread(infile2,'PB')+ncread(infile2,'P');  P100=P/100; %pressure in hPa 
  theta = ncread(infile2,'T')+300; 
  wstag = ncread(infile2,'W');
  qv2 = ncread(infile2,'QVAPOR');   
  %---  
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE'));  
  hyd2=qr+qc+qg+qs+qi;
  zg2=(PH0(:,:,1:end-1)+PH0(:,:,2:end))*0.5/g;   
  w2=(wstag(:,:,1:end-1)+wstag(:,:,2:end)).*0.5;     
  temperature2  = theta.*(1e3./P100).^(-Rcp); %temperature (K)   
%   ev=qv2./(epsilon+qv2).*P100;   %partial pressure of water vapor
%   Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor  
  Tv=temperature2.*(1+qv2/epsilon)./(1+qv2);
  dencity=P./Tv/Rd;      

  
  if nti==1; [nx, ny, nz]=size(theta); end
  
  for i=1:nx
    for j=1:ny  
      den_iso(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(dencity(i,j,:)),squeeze(X(3,nti,calpoint)),'linear'); 
      qv_iso(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(qv2(i,j,:)),squeeze(X(3,nti,calpoint)),'linear'); 
      theta_iso(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(theta(i,j,:)),squeeze(X(3,nti,calpoint)),'linear'); 
      
      p_iso1(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(P(i,j,:)),squeeze(X(3,nti,calpoint)),'linear'); 
      p_iso2(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(P(i,j,:)),squeeze(X(3,nti,calpoint)+10),'linear');       
    end
  end  
  den_hm=mean(den_iso,[1,2],'omitnan');
  qv_hm=mean(qv_iso,[1,2],'omitnan');
  theta_hm=mean(theta_iso,[1,2],'omitnan');
  
  p_hm1=mean(p_iso1,[1,2],'omitnan');
  p_hm2=mean(p_iso2,[1,2],'omitnan');
  

  if nti==1      
    dx=ncreadatt(infile2,'/','DX') ;    dy=ncreadatt(infile2,'/','DY') ;     
    xaxis=(1:nx)*dx;    yaxis=(1:ny)*dy; 
    [yi, xi]=meshgrid(yaxis,xaxis);
    hgt = ncread(infile2,'HGT');   
    xi3d=repmat(xi,1,1,nz);
    yi3d=repmat(yi,1,1,nz);
    
     
    for pj=1:np   
      pii=calpoint(pj);
      w_traj(nti,pj)   = w2 ( int_xps(pii),int_yps(pii),int_zps(pii) );
      t_traj(nti,pj)   = temperature2( int_xps(pii),int_yps(pii),int_zps(pii) );
      qv2_traj(nti,pj) = qv2 ( int_xps(pii),int_yps(pii),int_zps(pii) );
      hyd2_traj(nti,pj)= hyd2 ( int_xps(pii),int_yps(pii),int_zps(pii) );      
      qv1_traj(nti,pj) = qv1 ( int_xps(pii),int_yps(pii),int_zps(pii) );
      hyd1_traj(nti,pj)= hyd1 ( int_xps(pii),int_yps(pii),int_zps(pii) );
%     t_parcel(nti,:) = temperature(indx(1,:));
%     Td_point=Td(indx(1,:));

      theta_p=theta( int_xps(pii),int_yps(pii),int_zps(pii) ) - theta_hm(pj);     
      qv_p = qv2_traj(nti,pj) - qv_hm(pj);
      B_traj(nti,pj) =  g * (  theta_p/theta_hm(pj) + 0.61*qv_p);

      z1=X(3,nti,pii)-10;
      z2=X(3,nti,pii)+10;    
      P1=interp2(yi,xi,p_iso1(:,:,pj),X(2,nti,calpoint(pj)),X(1,nti,calpoint(pj)));
      P2=interp2(yi,xi,p_iso2(:,:,pj),X(2,nti,calpoint(pj)),X(1,nti,calpoint(pj)));

      P_p1 = P1 - p_hm1(pj);  
      P_p2 = P2 - p_hm2(pj);  

      pb_grad(nti,pj)= -(P_p2-P_p1)/(z2-z1)/den_hm(pj);

    end
    
  else    
    dis_x= repmat(xi3d,1,1,1,np)-repmat(reshape(X(1,nti,calpoint),1,1,1,np),nx,ny,nz,1);
    dis_y= repmat(yi3d,1,1,1,np)-repmat(reshape(X(2,nti,calpoint),1,1,1,np),nx,ny,nz,1);
    dis_z= repmat(zg2,1,1,1,np)-repmat(reshape(X(3,nti,calpoint),1,1,1,np),nx,ny,nz,1);
    dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;
    dist2=reshape(dist,nx*ny*nz,np);
    dist2(dist2>50000)=NaN;
    [~, indx]=sort(dist2); 
    dist_w=1./dist2;
    for pj=1:np
      dist_w_temp(:,pj)=dist_w(indx(1:num,pj),pj);    
    end
    %
    vari_temp=w2(indx(1:num,:));        
     w_traj(nti,:)=sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1);  %---inverse distance weighted mean---
    
    vari_temp=temperature2(indx(1:num,:));        
     t_traj(nti,:)=sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1);        
    vari_temp=qv2(indx(1:num,:));        
     qv2_traj(nti,:)=sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1); 
    vari_temp=hyd2(indx(1:num,:));        
     hyd2_traj(nti,:)=sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1);     
    vari_temp=qv1(indx(1:num,:));        
     qv1_traj(nti,:)=sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1);     
    vari_temp=hyd1(indx(1:num,:));        
     hyd1_traj(nti,:)=sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1);    
     
    vari_temp=theta(indx(1:num,:));
     theta_p = sum(vari_temp.*dist_w_temp,1)./sum(dist_w_temp,1)  - squeeze(theta_hm)';    
    qv_p=qv2_traj(nti,:) - squeeze(qv_hm)';      
    B_traj(nti,:) =  g * ( theta_p./squeeze(theta_hm)' + 0.61*qv_p);

    
    for pj=1:np
        [az,by,cz]=ind2sub([nx,ny,nz],indx(1,pj));
        if zg2(indx(1,pj))>X(3,nti,calpoint(pj))
            lev1=cz-1; lev2=cz;
        elseif zg2(indx(1,pj))<X(3,nti,calpoint(pj))
            lev1=cz; lev2=cz+1;
        end
        
        
      z1=X(3,nti,calpoint(pj))-10;
      z2=X(3,nti,calpoint(pj))+10;      
      
      P1=interp2(yi,xi,p_iso1(:,:,pj),X(2,nti,calpoint(pj)),X(1,nti,calpoint(pj)));
      P2=interp2(yi,xi,p_iso2(:,:,pj),X(2,nti,calpoint(pj)),X(1,nti,calpoint(pj)));     
        
      P_p1 = P1 - p_hm1(pj);  
      P_p2 = P2 - p_hm2(pj);  

      pb_grad(nti,pj)= -(P_p2-P_p1)/(z2-z1)/den_hm(pj);

        
    end
    
    
%   if t_parcel(nti-1,npi)>Td_point(npi)
%         t_parcel(nti,npi)=t_parcel(nti-1,npi) - g/cpd * (X(3,nti,pj)-X(3,nti-1,pj));
%   else    
%     lapse_w= g .* (Rd*t_parcel(nti-1,npi).^2 + Lv*qv_point.*t_parcel(nti-1,npi) ) ./...
%            (cpd*Rd*t_parcel(nti-1,npi).^2 + Lv^2*qv_point*epsilon);  
%     t_parcel(nti,npi)=t_parcel(nti-1,npi)-lapse_w;
%   end
      
  end
%   if mod(nti,5)==0
  disp([s_hr,s_min,' done'])
%   end
end

%%
% hf=figure('position',[100 200 1000 600]);
% plot(qv2_traj(:,2)*1e3,'linewidth',2)
% hold on
% plot(qv1_traj(:,2)*1e3,'linewidth',2,'linestyle','--')
%

%%
load('colormap/colormap_ncl.mat');
col=colormap_ncl(20:30:end,:);

[~, b]=sort(squeeze(X(3,end,calpoint)),'descend');
hyd2_traj(hyd2_traj+1<=1)=NaN;
hyd1_traj(hyd1_traj+1<=1)=NaN;
%%
%
hf=figure('position',[100 200 1000 600]);
subplot(3,1,1)
for pj=b'
%  plot(abs(qv1_traj(:,pj)-qv2_traj(:,pj))*1e3,'linewidth',2,'color',col(pj,:)); hold on
 plot(qv2_traj(:,pj)*1e3,'linewidth',2.5,'color',col(pj,:)); hold on
 plot(qv1_traj(:,pj)*1e3,'linewidth',2.5,'color',col(pj,:),'linestyle','--');
end
% set(gca,'xlim',[142 150])
% set(gca,'xlim',[120 180])

subplot(3,1,2)
for pj=b'
%  plot(abs(hyd1_traj(:,pj)-hyd2_traj(:,pj))*1e3,'linewidth',2,'color',col(pj,:)); hold on
 plot(hyd2_traj(:,pj)*1e3,'linewidth',2.5,'color',col(pj,:)); hold on
 plot(hyd1_traj(:,pj)*1e3,'linewidth',2.5,'color',col(pj,:),'linestyle','--');
end
% set(gca,'xlim',[142 150])
% set(gca,'xlim',[120 180])


subplot(3,1,3)
for pj=b'
 plot(X(3,:,calpoint(pj)),'linewidth',2.5,'color',col(pj,:)); hold on
end
% set(gca,'xlim',[142 150])
% set(gca,'xlim',[120 180])
%}
%%
hf=figure('position',[100 200 1000 600]);
subplot(2,1,1)
for pj=b'
 plot(pb_grad(:,pj),'linewidth',2.5,'color',col(pj,:)); hold on
 
 plot(B_traj(:,pj),'linewidth',2.5,'color',col(pj,:),'linestyle','--'); hold on
 
end
subplot(2,1,2)
for pj=b'
plot( (w_traj(1:end-1,pj)-w_traj(2:end,pj))/dt ,'linewidth',2.5,'color',col(pj,:),'linestyle','-.'); hold on
plot( pb_grad(:,pj)+B_traj(:,pj) ,'linewidth',2.5,'color',col(pj,:),'linestyle','-');
end
%%
% load('colormap/colormap_tern.mat')
% cmp = getPyPlot_cMap('terrain',30);
% cmp(1,:)=[1 1 1];
%---
%{
hgt(hgt+1==1)=NaN;
hf=figure('position',[100 200 985 755]);
surf(xi,yi,hgt,'linestyle','none')
cmp = getPyPlot_cMap('BuGn');
colormap(cmp)
hc=colorbar;
title(hc,'m')
%
hold on
for pj=1:np
 plot3(X(1,:,pj),X(2,:,pj),X(3,:,pj),'linewidth',3)
 plot3(X(1,1,pj),X(2,1,pj),X(3,1,pj),'xk','markersize',5,'linewidth',2)
end 
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Height (m)')
set(gca,'fontsize',16,'Xlim',[0 200000],'Ylim',[0 210000],'Zlim',[0 2500])
%
outfile=[outdir,'/',expri,'_dwdt-trajectary_2km'];
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
plot(t_traj(:,3),'linewidth',3)
hold on
% plot(t_parcel(:,3),'linestyle','--','linewidth',3)
set(gca,'xlim',[0 182])

subplot(3,1,2)
set(gca,'xlim',[0 182])
% plot(B_Euler(:,3),'linewidth',3)
hold on
plot((w_traj(2:end,3)-w_traj(1:end-1,3))/dt,'linewidth',3)
% line([1 size(B_Euler,1)],[0 0],'color','k')

subplot(3,1,3)
% plot(squeeze(X(3,:,[ 13])),'linewidth',3)
plot(squeeze(X(3,:,calpoint(3))),'linewidth',3)
set(gca,'xlim',[0 182])


outfile=[outdir,'/',expri,'_dwdt-trajectary'];
%  print(hf,'-dpng',[outfile,'.png'])    
%  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}