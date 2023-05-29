clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;    thresholds=[15]; 
kicksea=1; randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
 pltime=43; expri='Hagibis05kme02'; infilename='201910101800';%hagibis05
% pltime=[19]; expri='Hagibis01kme06'; infilename='201910111800'; expsize=1000;  %hagibis01
% pltime=[18 19 20 21]; expri='Hagibis01kme06'; infilename='201910111800'; expsize=600;  %hagibis01e06
% pltime=19; expri='H01MultiE0206'; infilename='201910111800'; expsize=1000;  %hagibis01e06
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  Wind speed probab.'];   fignam0=[expri,'_WindProb_'];   unit='%';
%
% plon=[134.8 143.5]; plat=[32.3 38.5];   lo_int=135:5:144; la_int=30:5:37; % Japan center of Kanto
% plon=[135 144.5]; plat=[32 39];  lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
plon=[135.5 142]; plat=[33.6 37.4]; fignam=[fignam0,'zkd2_'];  lo_int=134:2:145; la_int=31:2:40; % zoom in Kantou area

% plon=[138 141]; plat=[34 37.3]; fignam=[fignam0,'ktp_'];  lo_int=130:2:146; la_int=25:2:45; msize=13;  %Kantou portrait(verticle)
% plon=[138 141]; plat=[34 36.5]; fignam=[fignam0,'tkb_'];  lo_int=134:2:145; la_int=31:2:40; %Kantou portrait(verticle)2 

%
load('colormap/colormap_PQPF.mat') 
cmap0=colormap_PQPF; cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[10 30 50 70 90];
%---
infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm2.nc'];
terr = double(ncread(infile_hm,'terrain'));
land = double(ncread(infile_hm,'landsea_mask'));
indir_o='/data8/wu_py/Data/obs/';

%%
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);
    spd10_ens0=zeros(nx,ny,length(data_time),pltensize);      
  end  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,:,imem)=double(u10.^2+v10.^2).^0.5;  
  if mod(imem,100)==0; disp([num2str(imem),' done']); end
end  %imem
%%
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time); % for obs
% %---obs
%  nti=0;
%  obs_time=pltime-1:pltime;
%  for ti =obs_time
%    nti=nti+1;
%    time_o=datestr(pltdate(ti),'yyyymmddhhMM');
%    infile_o=[indir_o,'amds_',time_o,'.txt']; 
%    A=importdata(infile_o);   
%    if nti==1 
%     lon_o=A(:,7); lat_o=A(:,8); sta_num_ini=A(:,1); 
%     wind_speed=zeros(length(lon_o),length(obs_time));
%     wind_speed(:,nti)=A(:,9);
%    else
%     for ista=1:size(A,1)
%       fi=find(sta_num_ini==A(ista,1), 1);      
%       if isempty ( fi )==1
%       sta_num_ini(end+1)=A(ista,1);  lon_o(end+1)=A(ista,7); lat_o(end+1)=A(ista,8);
%         wind_speed(end+1,1:nti-1)=NaN;  wind_speed(end,nti)=A(ista,9);        
%       else              
%       wind_speed(fi,nti)=A(ista,9);
%       end
%     end % for ista
%   end %if nti==1   
%  end
%  obs_max=max(wind_speed,[],2);

%%
% pltensize=1000;

for ti=pltime     
 
 spd10_ens=squeeze(spd10_ens0(:,:,ti,:));
    
  %---probability for different thresholds
  for thi=thresholds      
    wind_pro=zeros(nx,ny);   
    for i=1:nx
      for j=1:ny
        wind_pro(i,j)=length(find(spd10_ens(i,j,1:pltensize)>=thi));
      end
    end
    wind_pro=wind_pro/pltensize*100;
    wind_pro(wind_pro+1==1)=NaN;
    if kicksea~=0;   wind_pro(land+1==1)=NaN;  end
    %%
    close all
    %---plot
    plotvar=wind_pro;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    % ens mean
%     m_contour(lon,lat,mean(spd10_ens,3),[thi thi],'r','linewidth',2); 

    %---coast line by mfhm
%     m_contour(lon,lat,land,[0.05 0.05],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')
        m_contour(lon,lat,land,[0.3 0.3],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--')

    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
%     m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int);
    % 
    tit={[titnam];[datestr(pltdate(ti),'mm/dd HHMM'),'  (',num2str(thi),' m/s, ',num2str(pltensize),' mem)']};   
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
%     set(hc,'position',[0.8 0.13 0.02 0.74]);

%     %---obs x---
%      fin=find(obs_max>=thi & lon_o<plon(2) & lat_o<plat(2));
%  m_plot(lon_o(fin),lat_o(fin),'x','color',[0.1 0.05 0.9],'linewidth',3,'Markersize',15)
%     outfile=[outdir,'/',fignam,datestr(pltdate(ti),'mmdd'),'_',datestr(pltdate(ti),'HHMM'),...
%         '_thrd',num2str(thi),'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem),'_obs'];

    outfile=[outdir,'/',fignam,datestr(pltdate(ti),'mmdd'),'_',datestr(pltdate(ti),'HHMM'),...
        '_thrd',num2str(thi),'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %thi
end % pltime
