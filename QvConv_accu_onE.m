% close all
clear;   ccc=':';

%---setting
expri='TWIN020B';  s_date='23';  hr=[0];  minu=50; 
% expri='TWIN021B';  s_date='23';  hr=[0];  minu=30; 


%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)


indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Water vapor convergence';   fignam=[expri,'_qv-conv_'];

load('colormap/colormap_br.mat')
% cmap=colormap_br([3 4 6 7 8 9 10],:);
cmap=colormap_br([2 3 4 5 6 7 8 9 10 11 13],:);

cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-0.03 -0.02 -0.01 -0.005 -0.001 0.001 0.005 0.01 0.02 0.03];
%---
% plev=[1000 950 900 850 700 500 200];
% intlev=[1000 700]
lev=10;
g=9.81;

%---
for ti=hr
  s_hr=num2str(ti,'%2.2d');  
  for mi=minu    
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    dx=ncreadatt(infile,'/','DX') ;  dy=ncreadatt(infile,'/','DY') ; 

    qv = ncread(infile,'QVAPOR');
    u.stag = ncread(infile,'U');   v.stag = ncread(infile,'V');     
    p = ncread(infile,'P');     pb = ncread(infile,'PB');  P=(p+pb); 
    hgt = ncread(infile,'HGT');   
    [nx, ny, ~]=size(p);
    %---
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    
    qv_u=qv.* u.unstag;
    qv_v=qv.* v.unstag;    
    
    dP=P(:,:,1:lev-1,:)-P(:,:,2:lev,:);
    
 
    qv_u_dp= dP.*( (qv_u(:,:,2:lev,:)+qv_u(:,:,1:lev-1,:)).*0.5 ) ;
    
    qv_v_dp= dP.*( (qv_v(:,:,2:lev,:)+qv_v(:,:,1:lev-1,:)).*0.5 ) ;
    
    qv_u_accu=squeeze(sum(qv_u_dp,3)./g);
    qv_v_accu=squeeze(sum(qv_v_dp,3)./g);

    
    u.conv=(qv_u_accu(2:end,:)-qv_u_accu(1:end-1,:))./dx;    u.conv(nx,:)=(qv_u_accu(1,:)-qv_u_accu(nx,:))./dx;
    v.conv=(qv_v_accu(:,2:end)-qv_v_accu(:,1:end-1))./dy;    v.conv(:,ny)=(qv_v_accu(:,1)-qv_v_accu(:,ny))./dy;
    
    plotvar=-(u.conv+v.conv);
    
     
   %%
    %---plot---
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 790 700]);
    [c, hp]=contourf(plotvar',L2,'linestyle','none');   hold on 
%         [c, hp]=contourf(plotvar','linestyle','none'); 
%         colorbar
%         colormap(colormap_br)
%         caxis([-max(caxis) max(caxis)])
%         caxis([-0.04 0.04])
%     %
%     h1 = quiver(xi,yi,u.plot1',v.plot1',0,'k') ; % the '0' turns off auto-scaling
%     hU = get(h1,'UData');   hV = get(h1,'VData') ;
%     set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.5);
%     %  
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
%     %
    set(gca,'fontsize',18,'LineWidth',1.2)     
%     set(gca,'Xlim',[1 nx],'Ylim',[1 ny])
       set(gca,'Xlim',[1 150],'Ylim',[26 175])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');
    tit={[expri,'  ',s_hrj,s_min,' LT'];[titnam,'  ','(lev1-',num2str(lev),')']};     
    title(tit,'fontsize',18)
%     
%     %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,'kg m^-^2 s^-^1','fontsize',14); 
drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end    
%     %---    
%  
%     outfile=[outdir,'/',fignam,num2str(p_int),'hpa_',mon,s_date,'_',s_hr,s_min];
%    print(hf,'-dpng',[outfile,'.png']) 
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   %}
  end %min
end

