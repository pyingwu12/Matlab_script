close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)

%---setting
expri='TWIN020B';  day=22;   hr=21;  minu=40;    
% p_int1=850;   p_int2=500;  z_int_w=2000;
p_int1=1000;   p_int2=900;  z_int_w=1000;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Convergence';   fignam=[expri,'_div_'];
%
load('colormap/colormap_br.mat')
cmap=colormap_br([2 3 4 6 7 8 9 10 11],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[-0.5 -0.3 -0.1 0.1 0.3 0.5];
% L=[-0.2 -0.1 -0.05 0.05 0.1 0.2];
L=[-2 -0.5 -0.2 -0.05 0.05 0.2 0.5 2];
%
g=9.81;
%
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d'); 
  for mi=minu    
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    u.stag = ncread(infile,'U');       v.stag = ncread(infile,'V');     
    w = double(ncread(infile,'W'));    
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  PH0=(phb+ph);  zg0=PH0/g;   

    p = ncread(infile,'P');     pb = ncread(infile,'PB');  P=(p+pb); 
    
    hgt = ncread(infile,'HGT');   
    [nx, ny, nz]=size(p);
    %---
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;  
    
    u.conv=(u.stag(2:end,:,:)-u.stag(1:end-1,:,:))./dx;  
    v.conv=(v.stag(:,2:end,:)-v.stag(:,1:end-1,:))./dy;  
    conv= -(u.conv+v.conv);
    
    fin=find(P/100>p_int1 | P/100<p_int2);
    conv(fin)=0;
     
    dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
    conv_int= dP.*( (conv(:,:,2:nz,:)+conv(:,:,1:nz-1,:)).*0.5 ) ;
    plotvar=squeeze(sum(conv_int,3)./g);
    
    for i=1:nx
      for j=1:ny
         w_iso(i,j)=interp1(squeeze(zg0(i,j,:)),squeeze(w(i,j,:)),z_int_w,'linear');
      end
    end        
    
%%
    %---plot---
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 800 730]);
    [c, hp]=contourf(plotvar',L2,'linestyle','none');   hold on 

    %
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.6 0.6 0.6],'linestyle','--','linewidth',2.5); 
    end
    %
    w_con=0.05;
    contour(w_iso',[w_con w_con],'color',[0 0 0],'linewidth',2.5)
    %
%     h1 = quiver(xi,yi,u.plot1',v.plot1',0,'k') ; % the '0' turns off auto-scaling
%     hU = get(h1,'UData');   hV = get(h1,'VData') ;
%     set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.5);
    %  
    set(gca,'fontsize',25,'LineWidth',2)           
    set(gca,'Xtick',[50 100 200 250],'Xticklabel',[50 100 200 250],'Ytick',0:50:300,'Yticklabel',0:50:300)
    set(gca,'xlim',[1 150],'ylim',[25 175])
    xlabel('(km)'); ylabel('(km)');
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  
    tit={[expri,'  ',s_hrj,s_min,' LT'];[titnam,'  ','(',num2str(p_int1),'-',num2str(p_int2),' hpa)'];...
        ['Updraft=',num2str(w_con),'ms^-^1  (',num2str(z_int_w/1e3),'km)']};     
    title(tit,'fontsize',18)
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,'kg m^-^2 s^-^1','fontsize',14);      drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end    
    %---    
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_p',num2str(p_int1),'-',num2str(p_int2),'_w',num2str(z_int_w/1e3),'km'];
   if saveid~=0
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   end
   %}
  end %min
end
