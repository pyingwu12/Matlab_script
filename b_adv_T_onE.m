

% close all
clear;   ccc=':';

%---setting
expri='TWIN024B';  s_date='22';   hr=22; minu=20;     p_int=850;  z_int_w=1000;
% int=12;  qscale=2;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)

indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Theta advention';   fignam=[expri,'_conv-int_'];

load('colormap/colormap_br.mat')
cmap=colormap_br([2 3 4 6 7 8 9 10 11],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[-0.5 -0.3 -0.1 0.1 0.3 0.5];
%
g=9.81;
%
%---
for ti=hr
  s_hr=num2str(ti,'%2.2d');  
  for mi=minu    
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    u.stag = ncread(infile,'U');       v.stag = ncread(infile,'V');     
    w = double(ncread(infile,'W'));    
    theda = ncread(infile,'T');  theda=theda+300;
    
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  PH0=(phb+ph);  zg0=PH0/g; 
    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g; 
    
    p = ncread(infile,'P');     pb = ncread(infile,'PB');  P=(p+pb); 
    
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;      

    
    hgt = ncread(infile,'HGT');   
    [nx, ny, nz]=size(p);
    %---
    grad_theda_x = (theda(2:end,:,:)-theda(1:end-1,:,:)) / dx;
     grad_theda_x(nx,:,:)= (theda(1,:,:)-theda(nx,:,:)) / dx;
    grad_theda_y = (theda(:,2:end,:)-theda(:,1:end-1,:)) / dy;
     grad_theda_y(:,ny,:) = (theda(:,1,:)-theda(:,ny,:)) / dy;
     
     adv_the = u.unstag.*grad_theda_x + v.unstag.*grad_theda_y;
     
%     adv_the(P/100<p_int)=0;
%      
%     dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
%     adv_int= dP.*( (conv(:,:,2:nz,:)+conv(:,:,1:nz-1,:)).*0.5 ) ;
%     plotvar=squeeze(sum(conv_int,3)./g);
% 
%     
    for i=1:nx
      for j=1:ny
%          w_iso(i,j)=interp1(squeeze(zg0(i,j,:)),squeeze(w(i,j,:)),1000,'linear');
         adv_iso(i,j)=interp1(squeeze(zg(i,j,:)),squeeze(adv_the(i,j,:)),z_int_w,'linear');
      end
    end        
    
%%
    %---plot---
    plotvar=adv_iso*1e3;
%     pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 800 680]);
%     [c, hp]=contourf(plotvar',L2,'linestyle','none');   hold on 
     [c, hp]=contourf(plotvar',20,'linestyle','none');   hold on 
    colorbar
%     contour(w_iso',[0.05 0.05],'color',[0 0 0],'linewidth',2.5)
    %
%     h1 = quiver(xi,yi,u.plot1',v.plot1',0,'k') ; % the '0' turns off auto-scaling
%     hU = get(h1,'UData');   hV = get(h1,'VData') ;
%     set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.5);
    %  
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',2); 
    end
    caxis([-1.5 1.5])
    %
%     set(gca,'fontsize',18,'LineWidth',1.2)     
%     set(gca,'Xlim',[1 nx],'Ylim',[1 ny])
       set(gca,'fontsize',25,'LineWidth',2)           
   set(gca,'Xtick',[100 200 250],'Xticklabel',[100 200 250],'Ytick',0:50:300,'Yticklabel',0:50:300)
%    xsub=1:150;  ysub=51:200;
   set(gca,'xlim',[1 150],'ylim',[25 175])

    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={[expri,'  ',s_hr,s_min,' UTC'];[titnam,'  ','(',num2str(z_int_w),' km)']};     
    title(tit,'fontsize',18)
    
    %---colorbar---
%     fi=find(L>pmin,1);
%     L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%     hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
%     colormap(cmap); title(hc,'kg m^-^2 s^-^1','fontsize',14);      drawnow;
%     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%     for idx = 1 : numel(hFills)
%       hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%     end    
    %---    
%  
%     outfile=[outdir,'/',fignam,num2str(p_int),'hpa_',mon,s_date,'_',s_hr,s_min];
%    print(hf,'-dpng',[outfile,'.png']) 
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   %}
  end %min
end
