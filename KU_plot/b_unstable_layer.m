% close all
clear;   ccc=':';

%---setting
expri='TWIN020B';  s_date='22';  hr=23;  minu=00; 
% expri='TWIN021B';  s_date='23';  hr=[0];  minu=30; 


%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)


indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='abs. unstable height';   fignam=[expri,'_abs-uns_'];

load('colormap/colormap_br.mat')
% cmap=colormap_br([3 4 6 7 8 9 10],:);
cmap=colormap_br([2 3 4 5 6 7 8 9 10 11 13],:);

cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-0.03 -0.02 -0.01 -0.005 -0.001 0.001 0.005 0.01 0.02 0.03];
%---
% plev=[1000 950 900 850 700 500 200];
% intlev=[1000 700]
g=9.81;

%---
for ti=hr
  s_hr=num2str(ti,'%2.2d');  
  for mi=minu    
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');

    
  
    theda=t+300;
    
    [nx, ny, ~]=size(theda);
    
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;      

    hgt = ncread(infile,'HGT');   

    diff_t=theda(:,:,2:end)-theda(:,:,1:end-1);
    
    
    
    for i=1:nx
        for j=1:ny
            idx_k=find(diff_t(i,j,:)>0,1)-1;
            if idx_k==0
              abs_un_h(i,j)=NaN;
            else                
              abs_un_h(i,j)=zg(i,j,idx_k)-hgt(i,j);
            end
        end
    end
    
    plotvar=abs_un_h';
   %%
    %---plot---
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 790 700]);
    [c, hp]=contourf(plotvar,'linestyle','none');   hold on 
 
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
%     %
    set(gca,'fontsize',18,'LineWidth',1.2)     
%     set(gca,'Xlim',[1 nx],'Ylim',[1 ny])
%        set(gca,'Xlim',[1 150],'Ylim',[26 175])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');
    tit={[expri,'  ',s_hrj,s_min,' LT'];titnam};     
    title(tit,'fontsize',18)
    
    colorbar

%  
%     outfile=[outdir,'/',fignam,num2str(p_int),'hpa_',mon,s_date,'_',s_hr,s_min];
%    print(hf,'-dpng',[outfile,'.png']) 
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   %}
  end %min
end

