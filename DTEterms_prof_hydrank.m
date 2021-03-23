close all
clear;   ccc=':';
%---setting
expri='TWIN021';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='22';  hr=23;  minu=50;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin']; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='hydro-rank-prof DTE terms';   fignam=[expri1(8:end),'_DTEterms_hydro-rank-prof_'];
%---
g=9.81;
zgi=10:50:12000;   ytick=1000:2000:zgi(end);

%---
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    
    hgt = ncread(infile2,'HGT');
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');    
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;          
    
    qr = ncread(infile2,'QRAIN');  qr=double(qr);   
    qs = ncread(infile2,'QSNOW');  qs=double(qs);    
    qg = ncread(infile2,'QGRAUP'); qg=double(qg);
    qi = ncread(infile2,'QICE');   qi=double(qi);
    qc = ncread(infile2,'QCLOUD'); qc=double(qc);
    hyd=qr+qs+qg+qi+qc; hyd=hyd*1e3;
    hyd2D=sum(hyd,3);
    [nx, ny, nz]=size(hyd);
    [~, hyd_rank]=sort(reshape(hyd2D,nx*ny,1),'descend'); 
    
    %
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qr = ncread(infile1,'QRAIN');  qr=double(qr);   
    qs = ncread(infile1,'QSNOW');  qs=double(qs);    
    qg = ncread(infile1,'QGRAUP'); qg=double(qg);
    qi = ncread(infile1,'QICE');   qi=double(qi);
    qc = ncread(infile1,'QCLOUD'); qc=double(qc);
    hyd1=(qr+qs+qg+qi+qc)*1e3; 
    %
    [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
    %    
%     cloud_len=length(find(hyd_sort>0.1));
    cloud_len=300;
    
    KE_vector=reshape(KE,nx*ny,nz);
    ThE_vector=reshape(ThE,nx*ny,nz);
    LH_vector=reshape(LH,nx*ny,nz);
    hyd_vector=reshape(hyd,nx*ny,nz);
    hyd1_vector=reshape(hyd1,nx*ny,nz);
    zg_vector=reshape(zg,nx*ny,nz);
    hgt_vector=reshape(hgt,nx*ny,1);


    KE_cloud=KE_vector(hyd_rank(1:cloud_len),:);
    ThE_cloud=ThE_vector(hyd_rank(1:cloud_len),:);
    LH_cloud=LH_vector(hyd_rank(1:cloud_len),:);
    hyd_cloud=hyd_vector(hyd_rank(1:cloud_len),:);
    hyd1_cloud=hyd1_vector(hyd_rank(1:cloud_len),:);
    
    zg_cloud=zg_vector(hyd_rank(1:cloud_len),:);
    hgt_cloud=hgt_vector(hyd_rank(1:cloud_len));
    
%---interpoltion---
    
    for i=1:cloud_len
        X=squeeze(zg_cloud(i,:));    
        Y=squeeze(hyd_cloud(i,:));     hyd_iso(i,:)=interp1(X,Y,zgi,'linear');    
        Y=squeeze(hyd1_cloud(i,:));    hyd1_iso(i,:)=interp1(X,Y,zgi,'linear'); 
        Y=squeeze(LH_cloud(i,:));      LH_iso(i,:)=interp1(X,Y,zgi,'linear');  
        Y=squeeze(ThE_cloud(i,:));     ThE_iso(i,:)=interp1(X,Y,zgi,'linear');  
        Y=squeeze(KE_cloud(i,:));      KE_iso(i,:)=interp1(X,Y,zgi,'linear');          
    end
[zi, xi]=meshgrid(zgi,1:cloud_len);

%%
    %---plot---          
    hf=figure('position',[100 200 1200 400]);
    
    contourf(xi,zi,hyd_iso,[0.1 0.1],'linestyle','none'); hold on  
    colormap([0.85 0.85 0.9])
    
    DTEcon=0.5;
    contour(xi,zi,KE_iso,[DTEcon DTEcon],'color',[0.3,0.745,0.933],'linewidth',1.5);     
    contour(xi,zi,ThE_iso,[DTEcon DTEcon],'color',[0.929,0.694,0.125],'linewidth',1.5);       
    contour(xi,zi,LH_iso,[DTEcon DTEcon],'color',[0.494,0.184,0.556],'linewidth',1.5);   

    hydcon=0.3;
    contour(xi,zi,hyd1_iso-hyd_iso,[hydcon hydcon],'color',[0.1 0.1 0.1],'linewidth',1.3,'Linestyle','-'); 
    contour(xi,zi,hyd1_iso-hyd_iso,[-hydcon -hydcon],'color',[0.1 0.1 0.1],'linewidth',1.3,'Linestyle','--'); 
    
%     plot(hgt_cloud,'k')
    hb=bar(hgt_cloud);    set(hb,'FaceColor',[0.466,0.574,0.188])
      

    set(gca,'fontsize',16,'LineWidth',1.2,'TickDir','out');       
    set(gca,'xlim',[1 200],'Ytick',ytick,'Yticklabel',ytick./1000)
    
    xlabel('Rank of vertical accumulated hydrometeor'); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1;[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']};     
    title(tit,'fontsize',18)   
    
    xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
    cld_loc=find(sum(hyd_cloud,2)<5,1);
    if cld_loc<=xlimit(2)
    line([cld_loc cld_loc],ylimit,'Linestyle','--','color','k','Linewidth',1.1)
    end
    
    rectangle('position',[170 5500 29 6300],'FaceColor','w')
    line([172 177],[11000 11000],'color',[0.494,0.184,0.556],'linewidth',2); text(179,11000,'Diff. LH','fontsize',15)
    line([172 177],[10000 10000],'color',[0.3,0.745,0.933],'linewidth',2); text(179,10000,'Diff. KE','fontsize',15)
    line([172 177],[9000 9000],'color',[0.929,0.694,0.125],'linewidth',2); text(179,9000,'Diff. ThE','fontsize',15)       
    line([172 177],[8000 8000],'color',[0.1 0.1 0.1],'linewidth',2); text(179,8000,'Diff. hyd.','fontsize',15)         
    rectangle('position',[172 6800 5 300],'FaceColor',[0.85 0.85 0.9],'EdgeColor','none'); text(179,7000,'hyd.','fontsize',15) 
    rectangle('position',[172 5850 5 200],'FaceColor',[0.466,0.574,0.188],'EdgeColor','none'); text(179,6000,'terrain','fontsize',15) 
    
%     text(5,11000,['3-D accumulated hydrometeors: ',num2str( sum(sum(hyd2D)) ),' (g Kg^-^1)'] )

   
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
%     print(hf,'-dpng',[outfile,'.png'])    
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %}
  end
end