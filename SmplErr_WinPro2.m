clear
% close all

saveid=0;

expsize=1000; 

BCnum=50;

expri0={'Hagibis05kme02';'Hagibis05kme01'}; 
nexp=size(expri0,1);
cexp=[0,0.447,0.741; 0.85,0.325,0.098];

% pltime=[28 31 34 37 40];  thresholds=[5 10 15 20 25]; 
pltime=[13 25 37 49];  %thresholds=[5 10 15 20 25]; 
thresholds=[5]; 

infilename='201910101800';    idifx=53; %hagibis05
%
indir='/obs262_data01/wu_py/Experiments/';  outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Wind prob. diff';   fignam='wind-prob-SamErr_';  

%%
%---read ensemble
% hf=figure('Position',[100 100 900 600]);

probdiff=zeros(expsize/BCnum-1,nexp,length(thresholds));
for iexp=1:nexp
  expri=expri0{iexp};
  if iexp==1
  infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
  infile=[indir,expri,'/',infilename,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];  
  data_time = (ncread(infile,'time'));    [nx, ny]= size(ncread(infile,'lat')) ; 
  nx1=nx-idifx*2+1; ny1=ny-idifx*2+1;  
  land = double(ncread(infile_hm,'landsea_mask',[idifx idifx],[nx1 ny1],[1 1]));
  fin=find(land<=0.2);  %!!!!!!!!!!!!!!
  end
  
  for ti=pltime  
      
    spd10_ens0=zeros(nx1,ny1,expsize);      
    for imem=1:expsize     
     infile=[indir,expri,'/',infilename,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];      
     u10 = ncread(infile,'u10m',[idifx idifx ti],[nx1 ny1 1],[1 1 1]);
     v10 = ncread(infile,'v10m',[idifx idifx ti],[nx1 ny1 1],[1 1 1]);
     spd10_ens0(:,:,imem)=double(u10.^2+v10.^2).^0.5;  
    end  %imem
    
    spd=reshape(spd10_ens0,nx1*ny1,expsize);
    spd=spd(fin,:);
    
    for thi=1:length(thresholds)     
        
      for ii=1:length(fin)
        count=zeros(expsize/BCnum,1);
        count(1)=length(find(spd(ii,1:BCnum)>=thresholds(thi) ));
        for isz=2:expsize/BCnum      
        tmp=length(find(spd(ii,(isz-1)*BCnum+1:isz*BCnum)>=thresholds(thi) ));
        count(isz)= count(isz-1)+tmp;      
        end
        count(count==0)=1e-16;
        prob=count./(BCnum:BCnum:expsize)';
        
        probdiff(:,iexp,thi) = probdiff(:,iexp,thi) + abs(log(prob(2:end)./prob(1:end-1))) / length(fin);
      end    
      
      disp(['thresholds ',num2str(thresholds(thi)),'m/s done']) 
    end
    
  end
  disp(['exp',num2str(iexp),' done']) 
end
  %%
figure; 
plot(100:50:1000,squeeze((probdiff(:,1,1))),'linestyle','--'); hold on
plot(100:50:1000,squeeze((probdiff(:,2,1))))