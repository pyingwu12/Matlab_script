% plot spread of TPW_qv (shaded) with ensembble mean of rainfall (contour)

close all
clear;  ccc=':';
%---
expri='ens07';  
year='2018'; mon='06';  s_date='22'; hr=7; minu=00;
dom='01';  dirmem='pert'; infilenam='wrfout'; 
ensize=10;  grids=1;%grid_spacing(km)
%
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
titnam='Total-qv Spread';   fignam=[expri,'_TPWqv-sprd_rain_'];
%

colormap_dte=[
    0.8467    0.9900    1.0000
    0.6990    0.9735    0.9900
    0.5225    0.8676    0.9800
    0.3461    0.7578    0.9343
    0.2284    0.7186    0.7186
    0.3382    0.8559    0.5422
    0.6990    0.9539    0.3069
    0.9735    0.9735    0.3735
    0.9804    0.8865    0.3447
    0.9847    0.8167    0.2873
    1.0000    0.5941    0.1931];

%load('colormap/colormap_pbl.mat')
cmap=colormap_dte; %cmap(1,:)=[1 1 1];
cmap(cmap>1)=1;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.2 0.5 1 1.5 2 2.5 3 3.5 4 4.5 ];
%
g=9.81;

for ti=hr 
   s_hr=num2str(ti,'%2.2d'); 
   for tmi=minu
     s_min=num2str(tmi,'%.2d');
     for mi=1:ensize
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %------read netcdf data--------
      qv =ncread(infile,'QVAPOR');
      p = ncread(infile,'P');  pb = ncread(infile,'PB');
      if mi==1
        [nx,ny,~]=size(qv);     TPWmem=zeros(nx,ny,ensize);  
        hgt=ncread(infile,'HGT'); 
        %--------read rainfall of ensemble mean--------------------
        for j=1:2
         hrr=ti+j-1;   hrday=fix(hrr/24);  hrr=hrr-24*hrday;
         s_dater=num2str(str2double(s_date)+hrday,'%2.2d');   s_hrr=num2str(hrr,'%2.2d');
         %------read netcdf data--------
         infile = [indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',s_dater,'_',s_hrr,':',s_min,':00'];
         rc{j} = ncread(infile,'RAINC');
         rsh{j} = ncread(infile,'RAINSH');
         rnc{j} = ncread(infile,'RAINNC');
        end %j=1:2
        rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
        rain(rain+1==1)=NaN;
      end
      %-------------------------------
      P=(pb+p);        dP=P(:,:,1:end-1)-P(:,:,2:end);    
      tpw= dP.*( (qv(:,:,2:end)+qv(:,:,1:end-1)).*0.5 ) ;   
      TPWmem(:,:,mi)=sum(tpw,3)./g;   
     end
     %---calculte spread---
     A=reshape(TPWmem,nx*ny,ensize);     
     am=mean(A,2);     Am=repmat(am,1,ensize);
     Ap=A-Am; 
     varae=sum(Ap.^2,2)./(ensize-1);    
     sprd=reshape(sqrt(varae),nx,ny);
     
     %---plot---
      plotvar=sprd';   %plotvar(plotvar<=0)=NaN;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
      fi=find(L>pmin);
       %
      hf=figure('position',[10 20 800 630]);   
      [c, hp]=contourf(plotvar,L2,'linestyle','none');       
      set(gca,'fontsize',16,'LineWidth',1.2)
      set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
      xlabel('(km)'); ylabel('(km)');
      
      hold on
      contour(rain',[1 1],'color',[0.2 0.2 0.2],'linewidth',1.5)
      
      if (max(max(hgt))~=0)
        hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
      end
      %      
      jhr=ti+9;  jhr=jhr-24*fix(jhr/24);  s_jhr=num2str(jhr,'%.2d');
      tit=[expri,'  ',titnam,'  ',s_jhr,s_min,' JST'];     
      title(tit,'fontsize',17)
% %---
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.1);
      colormap(cmap)
   
      drawnow;
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
         hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
      end   
%---    
       outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
       print(hf,'-dpng',[outfile,'.png']) 
       system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
     
   end %tmi
end