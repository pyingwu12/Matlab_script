

% close all
clear;   ccc=':';
%---setting
expri='TWIN025B';   day=22;  hr=23;  minu=10;  
%---
xp=1; yp=110;  %start grid
len=150;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Potential temperature';   fignam=[expri,'_cros-theta_'];
%---
g=9.81;
zlim=4000; ytick=500:500:zlim; 

for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    theda = ncread(infile,'T');  theda=theda+300;
    p = ncread(infile,'P'); pb = ncread(infile,'PB');
    P=p+pb;
    %---
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    hgt = ncread(infile,'HGT');
    %----       
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;     

    [nx, ny, ~]=size(ph);
    [y, x]=meshgrid(1:ny,1:nx);
 
%---decide cross section---       
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      Zaxis(:,i)=squeeze(zg(indx,indy,:));  
      theda_prof(:,i)=squeeze(theda(indx,indy,:));
      p_prof(:,i)=squeeze(p(indx,indy,:));
      pb_prof(:,i)=squeeze(pb(indx,indy,:));
      P_prof(:,i)=squeeze(P(indx,indy,:));
      hgtprof(i)=hgt(indx,indy);
    end    

%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';    xaxis=linex;  
    else;               xtitle='Y (km)';    xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
%%
%---theta_prof
    xi=repmat(xaxis*1e3,size(Zaxis,1),1);
    plotvar=p_prof/100;
    plotvar(Zaxis>zlim)=NaN;
    % 
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,Zaxis,plotvar,20,'linestyle','none'); 
%     
    hc=colorbar; 
%     caxis([301 318]); title(hc,'K')

    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end   
%     
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'xlim',[0 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)

    xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
    text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])

    xlabel(xtitle); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%.2d');
    tit=[expri,'  ',titnam,'  ',s_hrj,s_min,' LT'];     
    title(tit,'fontsize',18)  
%     %    
%     outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_z',num2str(zlim)];
%     print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
  end
end
