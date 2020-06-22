close all
clear
%---setting
expri='ens08';  ensize=10;  filt_len=30; dx=1;dy=1;
stdate=22;  sth=2;  acch=1;  
year='2018'; mon='06'; minu='00';  
dirmem='pert'; infilenam='wrfout';  dom='01';  grids=1;
%
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
%
titnam='Rainfall spread';   fignam=[expri,'_accum-sprd_L',num2str(filt_len),'_'];

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

cmap=colormap_dte; %cmap(1,:)=[1 1 1];
cmap(cmap>1)=1;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.1 0.5 1 3 5 9 12 15 18 21];
%

%
%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');  
  for ai=acch
    s_edh=num2str(mod(ti+ai,24),'%2.2d');  % end time string
%---read ensemble data---
   for mi=1:ensize
      nen=num2str(mi,'%.2d');  
      for j=1:2
        hr=(j-1)*ai+ti;
        hrday=fix(hr/24);  hr=hr-24*hrday;
        s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
        %------read netcdf data--------
        infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
        rc{j} = ncread(infile,'RAINC');
        rsh{j} = ncread(infile,'RAINSH');
        rnc{j} = ncread(infile,'RAINNC');
      end %j=1:2
      acci=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
      
      rainfilt(:,:,mi)=low_pass_filter(acci,filt_len,dx,dy);  %---LOW pass filter----
   end %mi
   hgt = ncread(infile,'HGT'); 
   [nx, ny,~]=size(rainfilt);  
   
   
   %---calculte spread---
   A=reshape(rainfilt,nx*ny,ensize);     
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
   
    
   if (max(max(hgt))~=0)
    hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
   end
      %      
   %jhr=ti+9;  jhr=jhr-24*fix(jhr/24);  s_jhr=num2str(jhr,'%.2d');
   %tit=[expri,'  ',titnam,'  ',s_jhr,minu,' JST'];     
   tit=[expri,'  ',titnam,'  ',s_sth,minu,'-',s_edh,minu,' UTC  (WL=',num2str(filt_len),'km)'];   
   title(tit,'fontsize',17)
%---
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.1);
   colormap(cmap)
  
   drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
   end   
%---    
   outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,minu];
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);            

  end  %ai
end  %ti
