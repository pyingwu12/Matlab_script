close all
clear;   ccc=':';
%---setting
expri='test45';
%year='2018'; mon='08'; date='19';
year='2018'; mon='06'; date='22';
hr=0:6; minu=00; infilenam='wrfout';  dom='01'; 
%---
xp=1; yp=100;  %start grid
len=249;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---
%indir=['E:/wrfout/expri191009/',expri];
%outdir='E:/figures/expri191009/';
indir=['/HDD003/pwin/Experiments/expri_test/',expri];
outdir='/mnt/e/figures/expri191009/';
titnam='Temperature';   fignam=[expri,'_Tprof_'];

load('colormap/colormap_zh.mat')
cmap=colormap_zh; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0 2 6 10 15 20 25 30 35 40 45 50 55 60 65 70];
%---
Rcp=287.43/1005; 
g=9.81;
zgi=[10,50,100:100:2500];    ytick=500:500:zgi(end); 

for ti=hr   
%  for mi=minu    
   %ti=hr; 
   mi=minu;
   %---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,s_min,ccc,'00'];
   t = ncread(infile,'T');   t=t+300;   
   ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
   p = ncread(infile,'P');   pb = ncread(infile,'PB');
   hgt = ncread(infile,'HGT');
   %----   
   P=p+pb;
   T=t.*(100000./P).^(-Rcp); %temperature
   PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g; 
   
   
   [nx, ny, nz]=size(t);
   [y, x]=meshgrid(1:ny,1:nx);
 
%---interpoltion---    
   i=0;  lonB=0; latB=0;
   while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
     i=i+1;
     indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
     linex(i)=x(indx,indy);  lonB=linex(i);     
     liney(i)=y(indx,indy);  latB=liney(i);       
     X=squeeze(zg(indx,indy,:));   Y=squeeze(T(indx,indy,:));   plotvar(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end 
      
   
   %---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi, zi]=meshgrid(linex,zgi);  xaxis=linex;
   else;               xtitle='Latitude';   [xi, zi]=meshgrid(liney,zgi);  xaxis=liney;
   end
   %---plot---   
   hf=figure('position',[-1100 200 900 600]);
   contourf(xi,zi,plotvar,20,'linestyle','none')
   colorbar
   caxis([285 305])
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',16,'LineWidth',1.2)
   ylabel('km')

   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)
%---    
   outfile=[outdir,'/',fignam,mon,date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png']) 
   
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);  
   
%  end
end