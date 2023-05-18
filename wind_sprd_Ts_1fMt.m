clear
% close all

saveid=0;

pltensize=50;  tint=6;
randmem=1; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

% expnam='Hagibis01kme02'; infilename='201910111800';  expsize=1000;%hagibis
expnam='H01MultiE0206'; infilename='201910111800';  expsize=1000;%hagibis
% expnam='Hagibis01kme06'; infilename='201910111800';  expsize=600;%hagibis

% expnam='Hagibis05kme02'; infilename='201910101800';%hagibis
% expnam='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expnam='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% convert_id=2; %1: duc-san default; 2: convert by wu (<-not used,fixed on 230212)
% expnam='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san) 
%
% expsize=1000;
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expnam,'  Wind spread'];   fignam=[expnam,'_wind-sprd-Ts_'];
%
%cvrt_name={'';'sfc'}; cvrt_time={'time';'times'};
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
%   infile=[indir,'/',num2str(member(imem),'%.4d'),'/',cvrt_name{convert_id},infilename,'.nc'];

  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon); ntime=length(data_time);   
    spd10_ens0=zeros(nx,ny,pltensize,ntime);
  end
  
  if isfile(infile) 
    u10 = ncread(infile,'u10m');
    v10 = ncread(infile,'v10m');
    spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5;  
  else
    spd10_ens0(:,:,imem,:) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end
    
end
disp('finished reading files')
%%
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);

%
%%
wind_sprd=std(spd10_ens0,0,3,'omitnan');
sprd_all=squeeze(mean(wind_sprd,[1 2]));

% clear pmsl_sprd
% pmsl_sprd=std(winspd0(:,:,:,1:BCnum),0,4);
% sprd_50=squeeze(mean(pmsl_sprd,[1 2]));
% 
% clear pmsl_sprd
% pmsl_sprd=std(winspd0(:,:,:,1:BCnum:pltensize),0,4);
% sprd_sameBC=squeeze(mean(pmsl_sprd,[1 2]));

%%
%---plot

hf=figure('Position',[100 100 1000 630]);  

plot(sprd_all,'linewidth',3,'linestyle','--') ; hold on 
% plot(sprd_50,'linewidth',2.5,'linestyle','-') ;
% plot(sprd_sameBC,'linewidth',2.5,'linestyle','-') ;

% legend('all','1-50','sameBC','box','off','location','nw','fontsize',22)
%---
xlabel('Time (UTC)');   ylabel('Spread (hPa)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:end),'HH'))
set(gca,'Ylim',[0 1.8])
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
