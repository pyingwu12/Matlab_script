% clear
% close all

saveid=1;
pltensize=500;  pltime=47;  

%
expri='H05km';
infilename='201910101800';
expsize=1000; 
%
indir='/data8/leduc/nhm/exp/Fugaku05km/forecast/Fugaku05km06/201910101800';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='10-m Wind speed (recenter)';   fignam=[expri,'_windhist-recent_']; 
%
load('H05km_center.mat')

%%     
%---read ensemble
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon); ntime=length(data_time);
    spd10_ens0=zeros(nx,ny,pltensize,ntime);     
  end  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
end  %imem
%%
      
%---calculate and plot at different times 
for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

  cen_idx=typhoon_center(ti,:);      
  [xp, yp]=ind2sub([nx ny],cen_idx);
  
  for imem=1:pltensize
  plotvar(imem)=spd10_ens0(xp(imem)+10,yp(imem),imem,ti);
  end
  %%
  hist_Edge=0:35;

  %---plot
  close all
  hf=figure('Position',[100 100 1000 630]);
  histogram(plotvar,'Normalization','probability','BinEdges',hist_Edge);  hold on
  %
  xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;  
yticklabels(yticks*100)
  %
%   x_lim=xlim; y_lim=ylim;
%   text(x_lim(2)-5,y_lim(2)+0.01,['xp=',num2str(xp),', yp=',num2str(yp)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit=[expri,'  ',titnam,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)'];   
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---  
end % pltime
  
