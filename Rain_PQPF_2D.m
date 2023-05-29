clear
close all

saveid=0;

pltensize=100;  pltime=6;   acch=3;   thresholds=10; 
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

% expri='Hagibis05kme01'; infilename='201910101800';%hagibis
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% convert_id=2; %1: duc-san default; 2: convert by wu (<-out of use,fixed on 230212)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san) 

expsize=1000; BCnum=50;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Rain Prob.'];   fignam=[expri,'_RainSprd2D_']; unit1='%'; unit2='mm';
%
load('colormap/colormap_PQPF.mat') 
cmap0=colormap_PQPF; cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[10 30 50 70 90];
%---
%---
plon=[121.3 138]; plat=[24.7 36.5];  lo_int=135:5:144; la_int=30:5:37; %kumakawa
% plon=[112 156]; plat=[18 50]; %Fugaku5km
% plon=[120 142]; plat=[25 38]; %nagasaki
% plon=[120 138.5]; plat=[26.5 38]; %nagasaki

%---
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];     
  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    [nx, ny, ntime]=size(ncread(infile,'rain'));
    rain0=zeros(nx,ny,ntime,pltensize);
    data_time = (ncread(infile,'time'));
  end  
  rain0(:,:,:,imem) = ncread(infile,'rain');    
end
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);

%%
%---plot
for ti=pltime     
  rain=squeeze(rain0(:,:,ti,:)-rain0(:,:,ti-acch,:));   
  %---probability for different thresholds
  for thi=thresholds      
    pqpf=zeros(nx,ny);   
    for i=1:nx
      for j=1:ny
        pqpf(i,j)=length(find(rain(i,j,1:pltensize)>=thi));
      end
    end
    pqpf=pqpf/pltensize*100;
    pqpf(pqpf+1==1)=NaN;
    %%
    %---plot
    plotvar=pqpf;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 

    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
%     m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int);
    % 
    tit={[titnam];[datestr(pltdate(ti-3),'mm/dd HHMM'),'-',datestr(pltdate(ti),'HHMM'),...
        '  (',num2str(thi),' ',unit2,', ',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)
    %
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); title(hc,unit1,'fontsize',15);  drawnow;  
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
%     set(hc,'position',[0.8 0.13 0.02 0.74]);
    
    outfile=[outdir,'/',fignam,datestr(pltdate(ti),'mmdd'),'_',datestr(pltdate(ti),'HHMM'),...
        '_thrd',num2str(thi),'_m',num2str(pltensize),'rnd',num2str(randmem)];

%     outfile=[outdir,'/',fignam,datestr(pltdate(ti),'mmdd'),'_',datestr(pltdate(ti),'HHMM'),...
%         '_thrd',num2str(thi),'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %thi
end % pltime