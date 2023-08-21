clear
% close all

saveid=0;

expri={'Hagibis05kme04';'Hagibis05kme03'};  
expnam={'ICP';'ICBCP'};
intag={'';'s';''};    outag='e03';
% cexp=[0.494,0.184,0.556;  0,0.447,0.741;  0.3,0.745,0.933];
cexp=[0.85,0.325,0.098;  0,0.447,0.741;  0.3,0.745,0.933];
infilename='201910101800';  idifx=53;  

pltensize=20;  
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

pltrng=[1  55];  pltint=1;
pltime=pltrng(1):pltint:pltrng(end);
tint=6; % for x tick
%
expsize=1000;  
%
indir='/obs262_data01/wu_py/Experiments';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Sea level pressure Spread';   fignam=['PmslFiltSprdTs_',outag,'_'];
%
ntime=length(pltime); nexp=size(expri,1);
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
sprdall=zeros(ntime,nexp);
sprdL=zeros(ntime,nexp);
sprdM=zeros(ntime,nexp);
sprdS=zeros(ntime,nexp);

infile=[indir,'/',expri{1},'/',infilename,'/',num2str(1,'%.4d'),'/',intag{1},infilename,'.nc']; 
[nx, ny, ~]=size(ncread(infile,'pmsl'));
for iexp=1:nexp
  for itime=1:ntime
 
    pmsl0=zeros(nx,ny,pltensize);
    pert_L=zeros(nx-idifx*2,ny-idifx*2,pltensize);
    pert_M=zeros(nx-idifx*2,ny-idifx*2,pltensize);
    pert_S=zeros(nx-idifx*2,ny-idifx*2,pltensize);
    
    for imem=1:pltensize 
     infile=[indir,'/',expri{iexp},'/',infilename,'/',num2str(member(imem),'%.4d'),'/',intag{iexp},infilename,'.nc'];   
     pmsl0(:,:,imem) = ncread(infile,'pmsl',[1 1 pltime(itime)],[Inf Inf 1],[1 1 1]);    
    end

    tmp=var(pmsl0(1+idifx:end-idifx,1+idifx:end-idifx,:),0,3);
    sprdall(itime,iexp)=sqrt(mean(tmp(:)));
    
    %---filtering---
    pert=pmsl0-repmat(mean(pmsl0,3),1,1,pltensize,1);
    for imem=1:pltensize  
     pert_L(:,:,imem) = filter2d(pert(1+idifx:end-idifx,1+idifx:end-idifx,imem),2000,20000,5,5);
     pert_M(:,:,imem) = filter2d(pert(1+idifx:end-idifx,1+idifx:end-idifx,imem),200,2000,5,5);
     pert_S(:,:,imem) = filter2d(pert(1+idifx:end-idifx,1+idifx:end-idifx,imem),1,200,5,5);
    end 
     tmp=var(pert_L,0,3);
    sprdL(itime,iexp)=sqrt(mean(tmp(:)));
     tmp=var(pert_M,0,3);
    sprdM(itime,iexp)=sqrt(mean(tmp(:)));
     tmp=var(pert_S,0,3);
    sprdS(itime,iexp)=sqrt(mean(tmp(:)));
    %----
    

  end
disp([expri{iexp},' done'])

end

%%
data_time = (ncread(infile,'time'));
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime));
%%
%---plot
%
hf=figure('Position',[2000 100 1000 630]);  
% for iexp=[3 1 2]  %1:nexp
for iexp=1:nexp
h(iexp)=plot(sprdall(:,iexp),'linewidth',3,'color',cexp(iexp,:)) ;  hold on
plot(sprdL(:,iexp),'linewidth',2,'color',cexp(iexp,:),'linestyle','--') 
plot(sprdM(:,iexp),'linewidth',2,'color',cexp(iexp,:),'linestyle','-.')
plot(sprdS(:,iexp),'linewidth',2,'color',cexp(iexp,:),'linestyle',':')
end
legend(h,expnam,'box','off','location','nw','fontsize',22)
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
