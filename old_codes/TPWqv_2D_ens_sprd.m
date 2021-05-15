% plot spread of TPW_qv (shaded) with ensembble mean of rainfall (contour)

close all
clear
%---setting
expri='ens09';  s_date='22';  hr=7;  minu=00;  ensize=10; 
rainid=0;
%---
year='2018'; mon='06';  
dirmem='pert';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri]; 
outdir=['/mnt/e/figures/ens200323/',expri];
%
titnam='PW spread';   fignam=[expri,'_TPWqv-sprd_',];
%
load('colormap/colormap_dte.mat')
cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.2 0.5 1 1.5 2 2.5 3 3.5 4 4.5 ];
%

for ti=hr 
  s_hr=num2str(ti,'%2.2d'); 
  for tmi=minu
    s_min=num2str(tmi,'%.2d');
    for mi=1:ensize
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
      %------read netcdf data--------
      qv =ncread(infile,'QVAPOR');
      p = ncread(infile,'P');  pb = ncread(infile,'PB');
      if mi==1
        [nx,ny,~]=size(qv);     TPWmem=zeros(nx,ny,ensize);  
        hgt=ncread(infile,'HGT'); 
        %--------read rainfall of ensemble mean--------------------
        if rainid~=0
         for j=1:2
          hr2=ti+j-1;   hrday=fix(hr2/24);  hr2=hr2-24*hrday;
          s_date2=num2str(str2double(s_date)+hrday,'%2.2d');   s_hr2=num2str(hr2,'%2.2d');
          %------read netcdf data--------
          infile = [indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',s_date2,'_',s_hr2,':',s_min,':00'];
          rall{j} = ncread(infile,'RAINC');
          rall{j} = rall{j} + ncread(infile,'RAINSH');
          rall{j} = rall{j} + ncread(infile,'RAINNC');
         end %j=1:2
         rain=double(rall{2}-rall{1});
        end % if rainid
      end % if mi==1
      %-------------------------------
      P=(pb+p);        dP=P(:,:,1:end-1)-P(:,:,2:end);    
      tpw= dP.*( (qv(:,:,2:end)+qv(:,:,1:end-1)).*0.5 ) ;   
      TPWmem(:,:,mi)=sum(tpw,3)./9.81;   
    end %mi
    %---calculte spread---
    A=reshape(TPWmem,nx*ny,ensize);     
    am=mean(A,2);     Am=repmat(am,1,ensize);
    Ap=A-Am; 
    varae=sum(Ap.^2,2)./(ensize-1);    
    sprd=reshape(sqrt(varae),nx,ny);     
    %
    %---plot---
    plotvar=sprd';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %
    hf=figure('position',[100 45 800 680]);
    [c, hp]=contourf(plotvar,L2,'linestyle','none');
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end    
    if rainid~=0
      contour(rain',[1 1],'color',[0.2 0.2 0.2],'linewidth',1.5)
    end
    %
    set(gca,'fontsize',16,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={expri;[titnam,'  ',s_hr,s_min,' UTC']}; 
    title(tit,'fontsize',18)
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,'Kg/m^2','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end  
    %---
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png'])       
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);      
  end %tmi
end %hr
