close all
clear;
ccc=':';
%---setting
expri='TWIN043'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
day=22;  hr=23;  minu=[0 10 20 30 40 50];  
saveid=1;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='hydro-rank-prof DTE';   fignam=[expri1(8:end),'_DTE_hydro-rank-prof_'];
%---
g=9.81;
zgi=10:50:7000;   ytick=1000:1000:zgi(end);
%---
terraincol=[0.466,0.574,0.188]; hydcol=[0.85 0.85 0.9];  DTElw=2.5;   hydcon=0.1;
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];    
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = ncread(infile2,'QRAIN');  qr=double(qr);   
     qs = ncread(infile2,'QSNOW');  qs=double(qs);    
     qg = ncread(infile2,'QGRAUP'); qg=double(qg);
     qi = ncread(infile2,'QICE');   qi=double(qi);
     qc = ncread(infile2,'QCLOUD'); qc=double(qc);
     hyd2=(qr+qs+qg+qi+qc)*1e3; 
     theta = ncread(infile2,'T');  theta=theta+300;

 
    hgt = ncread(infile2,'HGT');
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');    
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;          
    
    [nx, ny, nz]=size(hyd2);
    hyd2D=sum(hyd2,3);
    [~, hyd_rank]=sort(reshape(hyd2D,nx*ny,1),'descend'); 
    
    [DTE, ~]=cal_DTEterms(infile1,infile2);
        CMDTE=DTE.KE3D + DTE.SH + DTE.LH;
%    
%     cloud_len=length(find(hyd_sort>0.1));
    cloud_len=300;
    

    
    %---interpoltion---
    for i=1:nx
      for j=1:ny          
        X=squeeze(zg(i,j,:));       
        Y=squeeze(theta(i,j,:));   theta_iso(i,j,:)=interp1(X,Y,zgi,'linear');
      end
    end      
    theta_mean=mean(theta_iso,[1 2],'omitnan');
    theta_ano=theta_iso-repmat(theta_mean,nx,ny);            

    theta_ano_vector=reshape(theta_ano,nx*ny,length(zgi));
    theta_ano_cloud=theta_ano_vector(hyd_rank(1:cloud_len),:);
    

    
    CMDTE_vector=reshape(CMDTE,nx*ny,nz);
    hyd2_vector=reshape(hyd2,nx*ny,nz);
    
    zg_vector=reshape(zg,nx*ny,nz);
    hgt_vector=reshape(hgt,nx*ny,1);

    CMDTE_cloud=CMDTE_vector(hyd_rank(1:cloud_len),:);
    hyd2_cloud=hyd2_vector(hyd_rank(1:cloud_len),:);
        
    zg_cloud=zg_vector(hyd_rank(1:cloud_len),:);
    hgt_cloud=hgt_vector(hyd_rank(1:cloud_len));
    
%---interpoltion---    
    for i=1:cloud_len
        X=squeeze(zg_cloud(i,:));    
        Y=squeeze(hyd2_cloud(i,:));    hyd2_iso(i,:)=interp1(X,Y,zgi,'linear');    
        Y=squeeze(CMDTE_cloud(i,:));   CMDTE_iso(i,:)=interp1(X,Y,zgi,'linear');  
    end    
    %---
    [zi, xi]=meshgrid(zgi,1:cloud_len);
%%    
    hf=figure('position',[80 100 1200 400]);
    
    %---cloud shaded---
    contourf(xi,zi,hyd2_iso,[hydcon hydcon],'linestyle','none'); hold on  
    colormap(hydcol)
    %---DTE contours---
    [~, hplot(1)]=contour(xi,zi,CMDTE_iso,[0.5 0.5],'color',[57 139 227]/255,'linewidth',2);     
    [~, hplot(1)]=contour(xi,zi,CMDTE_iso,[5 5],'color',[22 83 126]/255,'linewidth',2);     
    
    %---
    [~, hplot(3)]=contour(xi,zi,theta_ano_cloud,[0.7 0.7],'color',[232 122 40]/255,'linewidth',1.5);     

    %---Terrain---
    if max(max(hgt))~=0
    hplot(2)=bar(hgt_cloud);    set(hplot(2),'FaceColor',terraincol)
    end
%-------  
    set(gca,'fontsize',16,'LineWidth',1.2,'TickDir','out');       
    set(gca,'xlim',[1 100],'Ytick',ytick,'Yticklabel',ytick./1000)
    
    xlabel('Rank of vertical accumulated hydrometeor'); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1;[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']};     
    title(tit,'fontsize',18)   
    
    xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
    %---cloud area dash line---
    cld_loc=find(sum(hyd2_cloud,2)<5,1);
    if cld_loc<=xlimit(2)
      line([cld_loc cld_loc],ylimit,'Linestyle','--','color','k','Linewidth',1.2)
    end
    
%     legend(hplot,'CMDTE','Terrain')
    ylabel('Height (km)')
    xlabel('Rank of vertical accumulated hydrometeor','fontsize',16);
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1;[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']};     
    title(tit,'fontsize',18)   
%-------  
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    
  end
end