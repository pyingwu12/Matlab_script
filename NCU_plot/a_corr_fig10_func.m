
clear

%hm=['00:00'; '00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00'];
%hm=['00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00'];
hm=['00:00'];
num=size(hm,1);

vonam='Vr';  vmnam='QRAIN';

expri='e01';     
infilenam='fcst';    dirnam='cycle';  type=infilenam;
%expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
memsize=40;     
ng=73; 
 
%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri];  %!!! use onlyobs when use obs to choicce points
indir2=['/SAS009/pwin/expri_largens/',expri]; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
%obsdir='/SAS004/pwin/data/obs_sz6414';

%---set
addpath('/work/pwin/m_map1.4/')
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];  
%
varinam=['Corr.(',corrvari,')'];    filenam=[expri,'_']; 
%
voen=zeros(memsize,1); 
g=9.81;


corr={}; nps=0;
for ti=1:num
    s_hr=hm(ti,1:2);  minu=hm(ti,4:5);

%---find small Vr point   
%=====================
%-------%!!! use <largens_wrf2obs_',expri/onlyobs> when use obs to choicce points--------------
%    infile=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%    A=importdata(infile); rad=A(:,1); ela=A(:,2); aza=A(:,3);  vr=A(:,8); 
%    fin_vr=find(rad==3 & aza>270 & ela<5 & vr+1>=1 & vr<=0.3);  svr=vr(fin_vr); saza=aza(fin_vr);
%=====================   
   infile=['/SAS011/pwin/201work/data/wrf2obs_uv/largens_wrf2obs_',expri,'/fcstmean','_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   A=importdata(infile); rad=A(:,1); ela=A(:,2); aza=A(:,3);  vr=A(:,8); 
   sou=A(:,10);  sov=A(:,11);   
   spe=sqrt(sou.^2+sov.^2);
   per=abs(vr./spe);
   fin_vr=find(per>=0.99 & rad==4 & ela<4 & aza>200 & aza<250);  svr=vr(fin_vr); saza=aza(fin_vr);
%   fin_vr=find(per<=0.01 & rad==3 & ela<4 & aza>290 & aza<340);  svr=vr(fin_vr); saza=aza(fin_vr); %use this
%    fin_vr=find(per<=0.01 & rad==3 & aza>270 );  svr=vr(fin_vr); saza=aza(fin_vr);
%    fin_vr=find(rad==3 & aza>270 & ela<5 & vr>=0 & abs(vr)<=0.1);  svr=vr(fin_vr); saza=aza(fin_vr);
%=====================
   length(fin_vr)
%   
   for oi=1:length(fin_vr);
                                                 tic
%---member
     for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d');
      infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
      infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------obs space------
      fid=fopen(infile1);
      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');      
      fin=fin_vr(oi);
      if     strcmp(vonam,'Vr')==1;  voen(mi)=vo{8}(fin); 
      elseif strcmp(vonam,'Zh')==1;  voen(mi)=vo{9}(fin); 
      else   error('Error: Wrong obs varible setting of <vonam>');  
      end      
      if voen(mi)==-9999; disp(['member ',nen,' obs is -9999']); voen(mi)=0;  end;       
%------model space----      
      ncid = netcdf.open(infile2,'NC_NOWRITE');       
      if mi==1
         if nps==0 
         %varid =netcdf.inqDimID(ncid,'west_east');   [~, nx]=netcdf.inqDim(ncid,varid);
         %varid =netcdf.inqDimID(ncid,'south_north'); [~, ny]=netcdf.inqDim(ncid,varid);
         varid =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
         varid  =netcdf.inqVarID(ncid,'XLONG');   x =netcdf.getVar(ncid,varid,'double');  
         varid  =netcdf.inqVarID(ncid,'XLAT');    y =netcdf.getVar(ncid,varid,'double'); 
         end
         %
         p_lon=vo{5}(fin); p_lat=vo{6}(fin); obs_hgt=vo{7}(fin); 
         %---difine px, py for th line---
         dis= ( (y-p_lat).^2 + (x-p_lon).^2 );
         [mid mxI]=min(dis);    [~, py]=min(mid);    px=mxI(py); %------------------------> px,py
         %
         varid  =netcdf.inqVarID(ncid,'PH');   ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
         varid  =netcdf.inqVarID(ncid,'PHB');  phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
         P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)./g;
         [~, lev]=min(abs(zg-obs_hgt));                          %------------------------> lev
         %---         
         vmen=zeros(ng,memsize);         
      end   % m==1        
      
      varid  =netcdf.inqVarID(ncid,vmnam);         
%     vm =netcdf.getVar(ncid,varid,[indx(1)-1 indy(np)-1 lev-1 0],[np np 1 1]);
%     for pi=1:ng;  vmen(pi,mi)=vm(1+pi-1,np-pi+1); end; 
      for i=1:ng
        vmen(i,mi) =netcdf.getVar(ncid,varid,[px-36+i-1-1 py+36-i+1-1 lev-1 0],[1 1 1 1]);   
        %vm =netcdf.getVar(ncid,varid,[indx(pi)-1 indy(pi)-1 lev-1 0],[2 2 1 1]);               
      end
      
      netcdf.close(ncid);
      fclose(fid);          
     end   %member
   
   %---estimate background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=vmen;                   b=voen;    
   at=mean(A,2);             bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                  be=b-bt;
   %---variance---    
   % !!note: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   nps=nps+1; disp(num2str(nps))
   corr{nps}=cov./(varae.^0.5)./(varbe^0.5);
   %corr(varae<1e-10)=NaN;
                                                     toc
   end  %oi
%}   
 figure('position',[1000 650 800 500]) 
 for oi=1:nps
  plot(corr{oi},'color',[0.9 0.2 0.1],'LineWidth',1.2);  hold on
 end 
% 
 xtick=[-36/2^0.5  -12/2^0.5   0   12/2^0.5   36/2^0.5]+((ng-1)/2+1);
 set(gca,'XLim',[1 ng],'Xtick',xtick,'XtickLabel',[-108 -36 0 36 108],'fontsize',13)
 set(gca,'YLim',[-0.8 0.8])
 xlabel('km','fontsize',14); ylabel('Error correlation','fontsize',14)
% 
% tit=[expri,'  ',varinam,'  ',s_hr,minu,'UTC  (',type,')'];  
% title(tit,'fontsize',15)
% 
% outfile=[outdir,'/',filenam,s_hr,minu,'_','_',type,'_',vonam,'-',lower(s_vm)];
% 
% set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
% system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
% system(['rm ',[outfile,'.pdf']]); 
 
end  %ti

%if memsize==256
%corr256da=corr;
%save([expri,'_corr_da.mat'],'corr256da')
%elseif memsize==40
%corr40da=corr;
%save('corr40_da.mat','corr40da')
%end   
   
