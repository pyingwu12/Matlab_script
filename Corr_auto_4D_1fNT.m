clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=500;  

pltime1=42;   Varnam1='u10m';
pltime2=45;   Varnam2='u10m';
%
expri='Hagibis05kme01'; infilename='201910101800';%hagibis
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=['Corr.(',Varnam1,', ',Varnam2,')'];   fignam=[expri,'_corr_'];  unit='m/s';
%
plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37];% fignam=[fignam,'2_']; 
%     plon=[134.5 143.5]; plat=[32 38.5];
%
load('colormap/colormap_br2.mat') 
cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:); 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];   


%%    
%---read ensemble
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);      
    data_time = (ncread(infile,'time'));
    Var1=zeros(nx,ny,pltensize,length(data_time));    
    Var2=zeros(nx,ny,pltensize,length(data_time)); 
  end  
  Var1(:,:,imem,:) = ncread(infile,Varnam1);    
  Var2(:,:,imem,:) = ncread(infile,Varnam2); 
end  %imem
%%
for ti1=pltime1 
  for ti2=pltime2
   %---estimate background error---
   % A:2-D, 3-dimention array
   A=Var1(:,:,:,ti1);  
   At=repmat(mean(A,3),1,1,pltensize);
   Ae=A-At;     
   
   B=Var2(:,:,:,ti2);  
   Bt=repmat(mean(B,3),1,1,pltensize);
   Be=B-Bt;  
   
   %---variance---    
   % notice: mean(Ae-Ae_bar)=0, i.e. mean of ensemble perturbation is expected to be zero, so it's ok to not minus mean
   a_cov=sum(Ae.*Be,3)/(pltensize-1); %covariance   
   %---correlation--- 
   varae=sum(Ae.^2,3)/(pltensize-1);
   varbe=sum(Be.^2,3)/(pltensize-1);
   a_corr=a_cov./(varae.^0.5)./(varbe.^0.5);
    
  pltdate1 = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti1));
  pltdate2 = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti2));
  
%%
%   close all
    %---plot
    plotvar=a_corr;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    %
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.95 0.95 0.95],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
    % 
%         % ens mean
%       plotcnt=[10 20 30]; cntcol=[0.1 0.1 0.1];
%   [c,hdis]=m_contour(lon,lat,squeeze(mean(spd10_ens,3)),plotcnt,'color',cntcol,'linewidth',1.8);     
% clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol)   
% %
%     tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
%     title(tit,'fontsize',18)
%     %
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
%     %
%     outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
%         '_m',num2str(pltensize)];
%     if saveid==1
%      print(hf,'-dpng',[outfile,'.png'])    
%      system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%     end
    %---

  end % pltime2
end % pltime1
