clear
% close all

saveid=0;

pltensize=100;  

pltrng=[7  49];  pltint=3; 
tint=1;%for x axis
pltime=pltrng(1):pltint:pltrng(end);

randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

expri='Hagibis05kme02'; infilename='201910101800';%hagibis

expsize=1000;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
msmindir='/data8/wu_py/Data/fcst_surf.nus';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Wind spread and RMSE'];   fignam=[expri,'_wind-sprd-Ts_'];
% titnam=[expri,'  pmsl Spread and RMSD to MSM'];   fignam=[expri,'_pmsl-rmse-Ts_'];
%
ntime=length(pltime);
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end

rmse=zeros(ntime,1); sprd=zeros(ntime,1);
for ti=1:ntime

for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   

  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon); 
    spd0=zeros(nx,ny,pltensize);
    pmsl=zeros(nx,ny,pltensize);
  end

    u10 = ncread(infile,'u10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);
    v10 = ncread(infile,'v10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);
    spd0(:,:,imem)=double(u10.^2+v10.^2).^0.5;  
    
    pmsl(:,:,imem) = ncread(infile,'pmsl',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);
    
end

% spd_sprd=std(spd10_ens0,[],3);

%---MSM----------
msmtime = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(ti))) + hours(3);
msminfilename=datestr(msmtime,'yyyymmddHHMM'); 
infileMSM=[msmindir,'/',msminfilename,'.nc'];
u10 = ncread(infileMSM,'u10m',[1 1 7],[Inf Inf 1],[1 1 1]);  
v10 = ncread(infileMSM,'v10m',[1 1 7],[Inf Inf 1],[1 1 1]);
spdMSM=double((u10.^2+v10.^2).^0.5);
pmslMSM = ncread(infileMSM,'pmsl',[1 1 7],[Inf Inf 1],[1 1 1]);  
% figure;contourf(pmslMSM')
%---MSM----------

sprd(ti) =  sqrt( mean( ( spd0-repmat(mean(spd0,3),1,1,pltensize) ).^2 ,'all' ) );
% sprd(ti) =  sqrt( mean( ( pmsl-repmat(mean(pmsl,3),1,1,pltensize) ).^2 ,'all' ) );

rmse(ti) =  sqrt( mean( (spdMSM-mean(spd0,3)).^2 ,'all' ) );
% rmse(ti) =  sqrt( mean( (pmslMSM-mean(pmsl,3)).^2 ,'all' ) );


end
%%
pltdate=datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime));
%---plot

hf=figure('Position',[100 100 1000 630]);  

plot(rmse,'linewidth',3,'linestyle','-') ; hold on 
plot(sprd,'linewidth',2.5,'linestyle','-') ;
% plot(sprd_sameBC,'linewidth',2.5,'linestyle','-') ;

legend('RMSE','Spread','box','off','location','nw','fontsize',22)
%---
xlabel('Time (UTC)');   ylabel('Spread (hPa)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate,'HH'))
% set(gca,'Ylim',[0 1.8])
%---date tick
%   yl=get(gca,'ylim');  text(0,yl(1)-3,[mm,'/',s_date],'fontsize',16)

  %---
  tit={titnam;['(',num2str(pltensize),' member)']};
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize),'rnd',num2str(randmem)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}

