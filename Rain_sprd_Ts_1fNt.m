clear
% close all

saveid=1;

pltensize=1000;  tint=6;


BCnum=50;

% expri='Hagibis05kme01'; infilename='201910101800';%hagibis
expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san) 

expsize=1000;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Spread of rainfall'];   fignam=[expri,'_rain-sprd-Ts_'];
%
%---
tmp=randperm(expsize); 
member=1:pltensize;  %!!!!!!!

for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  
  if imem==1
    [nx, ny, ntime]=size(ncread(infile,'pmsl'));
    rain0=zeros(nx,ny,ntime,pltensize);
  end  
  rain0(:,:,:,imem) = ncread(infile,'rain');    
end

data_time = (ncread(infile,'time'));
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

disp('finished reading files')
%
%
rain_sprd=std(rain0,0,4);
sprd_all=squeeze(mean(rain_sprd,[1 2]));

clear rain_sprd
rain_sprd=std(rain0(:,:,:,1:BCnum),0,4);
sprd_50=squeeze(mean(rain_sprd,[1 2]));

clear rain_sprd
rain_sprd=std(rain0(:,:,:,1:BCnum:pltensize),0,4);
sprd_sameBC=squeeze(mean(rain_sprd,[1 2]));

%%
%---plot

hf=figure('Position',[100 100 1000 630]);  

plot(sprd_all,'linewidth',3,'linestyle','--') ; hold on 
plot(sprd_50,'linewidth',2.5,'linestyle','-') ;
plot(sprd_sameBC,'linewidth',2.5,'linestyle','-') ;

legend('all','1-50','sameBC','box','off','location','nw','fontsize',22)
%---
xlabel('Time (UTC)');   ylabel('Spread (mm)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:end),'HH'))
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
