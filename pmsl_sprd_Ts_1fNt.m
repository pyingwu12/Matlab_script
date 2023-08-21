clear
% close all

saveid=0;

pltensize=20;  tint=6;
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

pltrng=[1  55];  pltint=1;
pltime=pltrng(1):pltint:pltrng(end);


expri='Hagibis05kme02'; infilename='201910101800'; fntag=''; %hagibis
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% convert_id=2; %1: duc-san default; 2: convert by wu (<-not used,fixed on 230212)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san) 
%
expsize=1000;  BCnum=50;  nsub=expsize/BCnum;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Spread of Sea level pressure'];   fignam=[expri,'_pmsl-sprd-Ts_'];
%
ntime=length(pltime);
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
sprdall=zeros(ntime,1);
sprd_same=zeros(ntime,BCnum);
sprd_diff=zeros(ntime,BCnum);

for ti=1:length(pltime)
infile=[indir,'/',num2str(1,'%.4d'),'/',fntag,infilename,'.nc']; 
    [nx, ny, ~]=size(ncread(infile,'pmsl'));
    %%
    pmsl0=zeros(nx,ny,pltensize);
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',fntag,infilename,'.nc'];   
  pmsl0(:,:,imem) = ncread(infile,'pmsl',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);    
end
% disp('end reading files')
%%
enme=mean(pmsl0,3);
sq=(pmsl0-repmat(enme,1,1,pltensize)).^2; 

sprdall(ti)=sqrt(mean(sq(:)));
% 
% for ibc=1:BCnum    
%   sprd_diff(ti)=sum(sq(:,:,(ibc-1)*nsub+1:ibc*nsub),'all');
%   sprd_same(ti)=sum(sq(:,:,ibc:BCnum:end),'all');
% end

% figure 
% tmp=squeeze(mean(sq,[1 2]));
% plot(tmp)


% disp([num2str(ti),' th time done'])
end
%%
data_time = (ncread(infile,'time'));
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime));
%%
%---plot

hf=figure('Position',[100 100 1000 630]);  

plot(sprdall,'linewidth',3,'linestyle','--') ; hold on 
% plot(sprd_50,'linewidth',2.5,'linestyle','-') ;
% plot(sprd_sameBC,'linewidth',2.5,'linestyle','-') ;

% legend('all','1-50','sameBC','box','off','location','nw','fontsize',22)
%---
xlabel('Time (UTC)');   ylabel('Spread (hPa)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:end),'HH'))
set(gca,'Ylim',[0 2.5])
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
