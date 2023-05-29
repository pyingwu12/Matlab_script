clear
% close all

saveid=0;

pltensize=1000;  tint=6;

expri='Hagibis05kme02'; infilename='201910101800';%hagibis
expsize=1000; 
infiletrackname='201910101800track';
%
% ntime=length(pltime);
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end

%
titnam='Track error';   fignam=[expri,'_TrackErr-Ts_'];
%
%---

%%
tmp=randperm(expsize); 
member=1:pltensize;  %!!!!!!!

for imem=1:pltensize 
 
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
  if imem==1
      data_time = (ncread(infile_track,'time'));
      ntime=length(data_time);
      lon_track=zeros(ntime,pltensize);
      lat_track=zeros(ntime,pltensize);
  end      
  
  if length(ncread(infile_track,'lon'))~=ntime
      disp(['member ',num2str(imem),' error'])
      lon_track(:,imem)=NaN;
      lon_track(:,imem)=NaN;
  else
  lon_track(:,imem) = ncread(infile_track,'lon');
  lat_track(:,imem) = ncread(infile_track,'lat');
  end
  
end

%% 
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
% 
% date_model=datestr(pltdate,'yyyymmddHHMM');
%
%%

%--best track
  infileo='/data8/wu_py/Data/Hagibis.txt';
  obs=importdata(infileo);
% best_pre=[950 950 965 975];
%--
for ti=1:size(obs,1)    
  if strcmp(num2str(obs(ti,1),'%12d'),infilename)        
  st_idx=ti;
  end
end

bestime_idx=st_idx:st_idx+floor(length(data_time)/6);
best_lon=obs(bestime_idx,2); best_lat=obs(bestime_idx,3);

 err_lon=lon_track(1:6:end,:)-repmat(best_lon,1,pltensize);
 err_lat=lat_track(1:6:end,:)-repmat(best_lat,1,pltensize);
 
 err_track=err_lon.^2+err_lat.^2;
 
 [~, mem_best]=min(mean(err_track(7:9,:),1));
%%
  %---plot
  
    %---plot
  hf=figure('Position',[100 100 1000 630]);  
  
  plot(err_track(:,3),'linewidth',2,'color',[0.95 0.85 0.1],'linestyle','-','Marker','none') ; hold on 
  
  %---
  xlabel('Time (UTC)');   ylabel('Error');
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 ceil(ntime/6)],'xtick',1:ceil(ntime/6),'Xticklabel',datestr(pltdate(1:6:end),'HH'))
set(gca,'yscale','log')
  %---date tick
%   yl=get(gca,'ylim');  text(0,yl(1)-3,[mm,'/',s_date],'fontsize',16)

  %---
  tit=[titnam,'  (',num2str(pltensize),' member)'];
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
