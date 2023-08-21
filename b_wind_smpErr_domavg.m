clear
% close all

saveid=0;

pltensize=1000;   

% pltime=[28 31 34 37 40 43]; 
pltime=[37];   nbst=10;
ensz=[5 10 20 40 80 160 320 600 800];

pltvari='wind';  %wind, u10m, or v10m
%
expri='Hagibis05kme01';  idifx=53;
infilename='201910101800';%hagibis
%
expsize=1000;  randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  ',pltvari,'  s.e.'];   fignam=[expri,'_',pltvari,'-se_'];  
%
%%  
infile=[indir,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];      
lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
[nx, ny]=size(lon);     data_time = (ncread(infile,'time'));  %ntime=length(data_time);   
%%
for ti=pltime     
  vari_ens=zeros(nx,ny,pltensize); 
  for imem=1:pltensize    
  infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];  
  if strcmp(pltvari,'wind')
    u=ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
    v=ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
    vari_ens(:,:,imem)= sqrt(u.^2 + v.^2) ;  
  else 
    vari_ens(:,:,imem)= ncread(infile,pltvari,[1 1 ti],[Inf Inf 1],[1 1 1]); 
  end
  end  %imem
  disp('end of reading files')
%%
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

%     dat=squeeze(mean(vari_ens,[1 2]));
  dat=squeeze(mean(vari_ens(1+idifx:end-idifx,1+idifx:end-idifx,:),[1 2]));
  %%
  nbst=10000;
%   for bst=1:nbst
%       tmp=randperm(expsize);
%   for isz=1:length(ensz)
%      
%       member=tmp(1:ensz(isz));
%       dat2=dat(member);
%       
%       datmu(bst,isz)=mean(dat2);
%   end
%   end
%   
%   figure; boxplot(datmu)
%   set(gca,'xticklabel',ensz)
  %%
%   for bst=1:nbst
%       tmp=randperm(expsize);
%   for isz=1:length(ensz)
%      
%       member=tmp(1:ensz(isz));
%       dat2=dat(member);
%       
%       datsig(bst,isz)=std(dat2);
%   end
%   end
%   
%   figure; boxplot(datsig)
%   set(gca,'xticklabel',ensz)
  
    %%
    p=0.9;
  for bst=1:nbst
      tmp=randperm(expsize);
  for isz=1:length(ensz)
     
      member=tmp(1:ensz(isz));
      dat2=dat(member);
      
      datpro(bst,isz)=quantile(dat2,p);
  end
  end
  
  figure; boxplot(datpro)
  set(gca,'xticklabel',ensz)
  title(expri)
end % pltime
