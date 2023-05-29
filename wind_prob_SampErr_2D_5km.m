clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

Lsize=1000;    Ssize=20;    

thresholds=[25]; 
kicksea=1; 
%
 pltime=43; expri='Hagibis05kme01'; infilename='201910101800';%hagibis05
% pltime=23; expri='Hagibis01kme02'; infilename='201910111800';%hagibis
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc',];

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=['Wind prob. diff'];   fignam=[expri,'_wind-prob-SamErr_'];   unit='%';
%
plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
% plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
%
load('colormap/colormap_br2.mat') 
cmap0=colormap_br2;  cmap=cmap0(3:2:end-1,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-15 -10 -5 -1 1 5 10 15];

%%
%---read ensemble
member=1:Lsize; 
for imem=1:Lsize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);
    spd10_ens0=zeros(nx,ny,Lsize,length(data_time));      
  end  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5;  
  if mod(imem,100)==0; disp(['Member ',num2str(imem),' done']); end
end  %imem
disp('end read files')
  %%
  
for ti=pltime(2:end)    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  spd10_ens=squeeze(spd10_ens0(:,:,:,ti));    
  %---probability for different thresholds
  for thi=thresholds      
    wind_proL=zeros(nx,ny); 
    wind_proS=zeros(nx,ny);   
    for i=1:nx
      for j=1:ny
        wind_proL(i,j)=length(find(spd10_ens(i,j,:)>=thi));
        wind_proS(i,j)=length(find(spd10_ens(i,j,1:Ssize)>=thi));
      end
    end
    wind_proL=wind_proL/Lsize*100;   
    wind_proS=wind_proS/Ssize*100; 
    SampE=wind_proS-wind_proL;
    if kicksea~=0;   SampE(land+1==1)=NaN;  end
    %%
    %---plot
    plotvar=SampE;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    % ens mean
%     m_contour(lon,lat,mean(spd10_ens,3),[thi thi],'r','linewidth',2); 
%     %
    m_contour(lon,lat,land,[0.2 0.2],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
%     m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    tit={[titnam,'(',num2str(Ssize),'-',num2str(Lsize),')'];[expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(thi),' m/s)']};   
    title(tit,'fontsize',18)
    %
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_thrd',num2str(thi),'_m',num2str(Lsize),'m',num2str(Ssize)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %thi
end % pltime

