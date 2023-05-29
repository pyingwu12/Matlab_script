clear
close all

saveid=0;

pltensize=10;  tint=6;
randmem=1; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

expri='Hagibis05kme02';  infilename='201910101800'; infiletrackname='201910101800track';%hagibis
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Center pressure'];   fignam=[expri,'_pmsl-Ts_'];
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize 
  if imem==1
    infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];  
    data_time = (ncread(infile,'time'));    ntime=length(data_time);
    %
    lon_track=zeros(ntime,pltensize);
    lat_track=zeros(ntime,pltensize);
    pmsl_track=zeros(ntime,pltensize);
  end  
  %---read tracks and center pressure
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
  len_track=length(ncread(infile_track,'lon'));
  if len_track~=ntime
    lon_track(1:len_track,imem) = ncread(infile_track,'lon');
    lat_track(1:len_track,imem) = ncread(infile_track,'lat');
    pmsl_track(1:len_track,imem) = ncread(infile_track,'pmsl');
  else
    lon_track(:,imem) = ncread(infile_track,'lon');
    lat_track(:,imem) = ncread(infile_track,'lat');
    pmsl_track(:,imem) = ncread(infile_track,'pmsl');
  end  
end %imem
lon_track(lon_track==0) =NaN; lat_track(lat_track==0) =NaN;  pmsl_track(pmsl_track==0) =NaN;
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
%%
%--best track
infileo='/data8/wu_py/Data/Hagibis.txt';
best=importdata(infileo);
for ti=1:size(best,1)    
  if strcmp(num2str(best(ti,1),'%12d'),infilename)        
  st_idx=ti;
  end
end
bestime_idx=st_idx:st_idx+floor(ntime/6);
best_p=best(bestime_idx,4);
%%
%---plot
hf=figure('Position',[100 100 1000 630]);  
%---members
plot(pmsl_track,'linewidth',2,'color',[0.95 0.85 0.1],'linestyle','-','Marker','none') ; hold on 
%---mean
plot(mean(pmsl_track,2,'omitnan'),'color',[0.8 0.7 0.05],'linewidth',2.3)
%---best track
plot(1:6:ntime,best_p,'ok','MarkerFaceColor','k','linestyle','-.','linewidth',1.5)
%
xlabel('Time (UTC)');   ylabel('Pressure (hPa)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:end),'HH'))
%---date tick
yl=get(gca,'ylim');  text(-1,yl(1)-6,datestr(pltdate(1),'mm/dd'),'fontsize',16)
%
tit=[titnam,'  (',num2str(pltensize),' member)'];
title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,'m',num2str(pltensize)];
if saveid~=0
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
