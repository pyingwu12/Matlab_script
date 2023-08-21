
function bc_rank_Ts(expri,intv,navg,lev)
% clear
% close all

% saveid=0;

pltensize=1000;    
randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members
%
pltrng=[1 55];  pltint=1;  infilename='201910101800';  %idifx=53;  %hagibis
% pltrng=[1 28];  pltint=1;  infilename='202108131200';  %idifx=53;  %hagibis

% tor=0.35;
% intv=[1 3 5 10]; % <-interval of grid point 
% navg=[1 5 10];
% lev=1000;
% expri='Hagibis05kme02'; 

pltime=pltrng(1):pltint:pltrng(end);

%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
% outdir=['/home/wu_py/labwind/Result_fig/',expri];
% if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
% titnam=[expri,'  Similarity between members'];   fignam=[expri,'_SimiTs_'];
%
ntime=length(pltime);
%   
%---read ensemble
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%%
%  rk50=zeros(1,ntime);  rkBC=zeros(1,ntime);  rkall=zeros(1,ntime);
% s_value=zeros(pltensize,ntime);
 
infile=[indir,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];
% lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));  
plev=double(ncread(infile,'lev'));   ilev=find(plev==lev);
% data_time = (ncread(infile,'time'));    
[nx, ny]=size(ncread(infile,'lat')); 
% pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime));

for ti=1:ntime
  disp([num2str(ti),' th time doing...']);
  u=zeros(nx,ny,pltensize);    v=zeros(nx,ny,pltensize); 
  T=zeros(nx,ny,pltensize);    q=zeros(nx,ny,pltensize);  
  for imem=1:pltensize     
    infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
    u(:,:,imem) = ncread(infile,'u',[1 1 ilev pltime(ti)],[Inf Inf 1 1],[1 1 1 1]); 
    v(:,:,imem) = ncread(infile,'v',[1 1 ilev pltime(ti)],[Inf Inf 1 1],[1 1 1 1]);
    T(:,:,imem) = ncread(infile,'t',[1 1 ilev pltime(ti)],[Inf Inf 1 1],[1 1 1 1]);
    q(:,:,imem) = ncread(infile,'qv',[1 1 ilev pltime(ti)],[Inf Inf 1 1],[1 1 1 1]);   
    if mod(imem,300)==0; disp([' ',num2str(imem),'mem done reading file']); end
  end  %imem    
  umean = mean(u,3); up=u-repmat(umean,1,1,pltensize);
  vmean = mean(v,3); vp=v-repmat(vmean,1,1,pltensize);
  Tmean = mean(T,3); Tp=T-repmat(Tmean,1,1,pltensize);
  qmean = mean(q,3); qp=q-repmat(qmean,1,1,pltensize);  
  clear u v T q umean vmean qmean Tmean
  %
  %%   
 for iintv=intv
     for iavg=navg
  us=squeeze( mean(up(1+iavg:iintv:end-iavg, 1:iavg, :),2) );
  un=squeeze( mean(up(1+iavg:iintv:end-iavg, end-iavg+1:end, :),2) );
  ue=squeeze( mean(up(end-iavg+1:end, 1:iintv:end, :),1) );
  uw=squeeze( mean(up(1:iavg, 1:iintv:end, :),1) ); 
  
  vs=squeeze( mean(vp(1+iavg:iintv:end-iavg, 1:iavg, :),2) ); 
  vn=squeeze( mean(vp(1+iavg:iintv:end-iavg, end-iavg+1:end, :),2) ); 
  ve=squeeze( mean(vp(end-iavg+1:end, 1:iintv:end, :),1) );
  vw=squeeze( mean(vp(1:iavg, 1:iintv:end, :),1) );  

  qs=squeeze( mean(qp(1+iavg:iintv:end-iavg, 1:iavg, :),2) ); 
  qn=squeeze( mean(qp(1+iavg:iintv:end-iavg, end-iavg+1:end, :),2) ); 
  qe=squeeze( mean(qp(end-iavg+1:end, 1:iintv:end, :),1) );
  qw=squeeze( mean(qp(1:iavg, 1:iintv:end, :),1) ); 

  Ts=squeeze( mean(Tp(1+iavg:iintv:end-iavg, 1:iavg, :),2) ); 
  Tn=squeeze( mean(Tp(1+iavg:iintv:end-iavg, end-iavg+1:end, :),2) );
  Te=squeeze( mean(Tp(end-iavg+1:end, 1:iintv:end, :),1) );
  Tw=squeeze( mean(Tp(1:iavg, 1:iintv:end, :),1) ); 
   
 tmp=vertcat(us,ue,un,uw,vs,ve,vn,vw,qs,qe,qn,qw,Ts,Te,Tn,Tw);

[~,S,~] = svd(tmp);

for i=1:pltensize
    
    eval(['s_value_i',num2str(iintv),'a',num2str(iavg),'(i,ti)=S(i,i);'])
%     s_value(i,ti)=S(i,i);
    
end



     end %avg
 end %intv


end  %time

for iintv=intv
     for iavg=navg
 
         eval(['outfilename="',expri,'_edge',num2str(iavg),'int',num2str(iintv),'lev',num2str(lev),...
    '_t',num2str(pltrng(1)),'_',num2str(pltrng(end)),'_',num2str(pltint),'_SV.mat";'])


         
save(outfilename,['s_value_i',num2str(iintv),'a',num2str(iavg)])


     end
end
%%
% figure
% plot(s_value)
% hold on
% line([50 50],[0 350],'linestyle','--','color',[0.7 0.7 0.7],'linewidth',2.5)
% line([25 25],[0 350],'linestyle','--','color',[0.7 0.7 0.7],'linewidth',1.5)

% hold on
% plot(rk50)
% plot(rkBC)