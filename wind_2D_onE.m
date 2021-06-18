close all
clear;   ccc=':';

%---setting
expri='TWIN003B';  s_date='22'; hr=23; minu=0;     p_int=950;
int=12;  qscale=2;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)

indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Convergence';   fignam=[expri,'_conv_'];

load('colormap/colormap_br.mat')
cmap=colormap_br([3 4 6 7 8 9 10],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-7 -4 -1 1 4 7 ];
%---
for ti=hr
  s_hr=num2str(ti,'%2.2d');  
  for mi=minu    
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');     
    p = ncread(infile,'P');     pb = ncread(infile,'PB');  P=(p+pb)/100; 
    hgt = ncread(infile,'HGT');   
    [nx, ny, ~]=size(p);
    %---
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;  
    for i=1:nx
      for j=1:ny         
         u.iso(i,j)=interp1(squeeze(P(i,j,:)),squeeze(u.unstag(i,j,:)),p_int,'linear');
         v.iso(i,j)=interp1(squeeze(P(i,j,:)),squeeze(v.unstag(i,j,:)),p_int,'linear');            
      end
    end    
    u.conv=(u.iso(2:end,:)-u.iso(1:end-1,:))./1000;    u.conv(nx,:)=(u.iso(1,:)-u.iso(nx,:))./1000;
    v.conv=(v.iso(:,2:end)-v.iso(:,1:end-1))./1000;    v.conv(:,ny)=(v.iso(:,1)-v.iso(:,ny))./1000; 
    plotvar=-(u.conv+v.conv)*1e4;
    
    %---
    u.plot1=u.iso(1:int:end,1:int:end);   v.plot1=v.iso(1:int:end,1:int:end);
    [xi, yi]=meshgrid(1:int:nx, 1:int:ny);
   %%
    %---plot---
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 800 680]);
    [c, hp]=contourf(plotvar',L2,'linestyle','none');   hold on 
    %
    h1 = quiver(xi,yi,u.plot1',v.plot1',0,'k') ; % the '0' turns off auto-scaling
    hU = get(h1,'UData');   hV = get(h1,'VData') ;
    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.5);
    %  
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',18,'LineWidth',1.2)     
    set(gca,'Xlim',[1 nx],'Ylim',[1 ny])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={[expri,'  ',s_hr,s_min,' UTC'];[titnam,'  ','(',num2str(p_int),'hpa)']};     
    title(tit,'fontsize',18)
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,'10^-^4 s^-^1','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end    
    %---    
 
    outfile=[outdir,'/',fignam,num2str(p_int),'hpa_',mon,s_date,'_',s_hr,s_min];
%    print(hf,'-dpng',[outfile,'.png']) 
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   %}
  end %min
end

