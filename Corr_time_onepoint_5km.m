clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;  

lonp=140; latp=35;
% xp=561; yp=346;

Varnam1='v10m';  Varnam2='v10m';
pltime=40;  len=12;    tint=3;
%
expnam='Hagibis05kme01'; infilename='201910101800';%hagibis
expsize=1000;
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
titnam=['Corr.(',Varnam1,', ',Varnam2,')'];   fignam=[expnam,'_',Varnam1,'-',Varnam2,'_'];  
%

%%    
%---read ensemble
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    dis_p=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_p==min(dis_p(:)));

    [nx, ny]=size(lon);      
    data_time = (ncread(infile,'time'));
    Var1=zeros(nx,ny,pltensize,length(data_time));    
    Var2=zeros(nx,ny,pltensize,length(data_time)); 
  end  
  Var1(:,:,imem,:) = ncread(infile,Varnam1);    
  Var2(:,:,imem,:) = ncread(infile,Varnam2); 
end  %imem
%%
%
pltensize=100;
calrange=2; calint=2;
clear corr_ab

for ti=pltime 
    np=0;
    
      pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

    for xpi=xp-calrange:calint:xp+calrange
        for ypi=yp-calrange:calint:yp+calrange
    np=np+1;
   % A: var1 at point(xp,yp) at t=ti;
   A=squeeze(Var1(xpi,ypi,1:pltensize,ti));  
   At=mean(A);
   Ae=A-mean(A);
   
   % A: var2 at point(xp,yp) at t=ti-len~ti+len;
   B=squeeze(Var2(xpi,ypi,1:pltensize,ti-len:ti+len)); 
   Bt=repmat(mean(B,1),pltensize,1);
   Be=B-Bt;  
   
   %---correlation--- 
   % notice: mean(Ae-Ae_bar)=0, i.e. mean of ensemble perturbation is expected to be zero, so it's ok to not minus mean
   cov_ab=Ae'*Be/(pltensize-1); %covariance   
   varae=sum(Ae.^2)/(pltensize-1); % equal to std(Ae)^2
   varbe=sum(Be.^2,1)/(pltensize-1);
   corr_ab(:,np)= cov_ab/(varae.^0.5)./(varbe.^0.5);
     
        end
    end
    %---plot
 
   hf=figure('Position',[100 100 900 580]);
plot(corr_ab,'linewidth',1.5,'color',[0,0.447,0.741])
 
  xlabel('Time (h)');   ylabel('Correlation');
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 len*2+1],'Xtick',1:tint:len*2+1,'Xticklabel',-len:tint:len)

    tit={[titnam,' around (',num2str(lonp),', ',num2str(latp),')'];...
       [expnam,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
  title(tit,'fontsize',18)

  
%   set(gca,'ylim',[-0.8 1.2])
  
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_',num2str(len),...
            'h_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---

end % pltime1
%}
