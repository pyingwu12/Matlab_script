%function Corr(hm,expri,varid)

clear
hm=['16:00'];   expri='MRcycle06';  vzind=3;  typem='qr';

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br2.mat'

indir1=['/work/pwin/data/morakot_wrf2obs_',expri];
indir2=['/SAS002/pwin/expri_241/morakot_',expri];  %%%
%indir2=['/SAS002/pwin/expri_241/morakot_newda_1518_vrzh_900'];  %%%
outdir=['/work/pwin/plot_cal/Corr./',expri,'/'];
%
vari='Corr.';   filenam=[expri,'_corr'];    
%----
num=size(hm,1);
%cmap=colormap_br2(:,1:2:21)';
cmap=colormap_br2([2 3 4 5 7 8 9 11 13 14 15 17 18 19 20],:);
%cmap=colormap_br2(:,2:20)';
%L=[-0.5 -0.4 -0.3 -0.2 -0.1   0.1 0.2 0.3 0.4 0.5];
L=[-0.7:0.1:-0.1,0.1:0.1:0.7];
%L=[-0.9:0.1:-0.1, 0.1:0.1:0.9];
lev=7;

%
%---
for ti=1:num;
   time=hm(ti,:);
   s_hr=time(1:2);
   %
%===wrf======
   for mi=1:40;
% ---filename----
      nen=num2str(mi);
      if mi<=9
       infile1=[indir1,'/fcst_d03_2009-08-08_',time,':00_0',nen];
       %infile2=[indir2,'/MRwork/new/wrfinput_d03_2009-08-08_',s_hr,':00:00_0',nen];
       infile2=[indir2,'/cycle0',nen,'/fcst_d03_2009-08-08_',s_hr,':00:00'];
      else
       infile1=[indir1,'/fcst_d03_2009-08-08_',time,':00_',nen];
       %infile2=[indir2,'/MRwork/new/wrfinput_d03_2009-08-08_',s_hr,':00:00_',nen];
       infile2=[indir2,'/cycle',nen,'/fcst_d03_2009-08-08_',s_hr,':00:00'];
      end      
%------obs space------
      A=importdata(infile1); 
      ela=A(:,2); aza=A(:,3); dis=A(:,4); height=A(:,7);
      fin=find(ela==0.5 & aza==178 & dis==73);   %%
      vr(mi)=A(fin,8);  zh(mi)=A(fin,9);   
      if vr(mi)==-9999; disp([num2str(mi),' vr is -9999']); vr(mi)=0;  end;
      if zh(mi)==-9999; disp([num2str(mi),' zh is -9999']); zh(mi)=0;  end;
%------model space----         
      ncid = netcdf.open(infile2,'NC_NOWRITE');     
      switch(typem)
        case('qr')  
         varid  =netcdf.inqVarID(ncid,'QRAIN');   
         varim0=(netcdf.getVar(ncid,varid)); 
        case('v')
         varid  =netcdf.inqVarID(ncid,'V');   V  =(netcdf.getVar(ncid,varid)); 
         nn=size(V,1);
         varim0=(V(:,1:nn,:)+V(:,2:nn+1,:)).*0.5;
        case('u')
         varid  =netcdf.inqVarID(ncid,'U');   U  =(netcdf.getVar(ncid,varid)); 
         nn=size(U,2);
         varim0=(U(1:nn,:,:)+U(2:nn+1,:,:)).*0.5;             
      end
%---
      varim(:,:,mi)=varim0(:,:,lev); 
      if mi~=40; netcdf.close(ncid); end
   end %member
%
   varid  =netcdf.inqVarID(ncid,'XLONG');  lonm =netcdf.getVar(ncid,varid);   x=double(lonm);
   varid  =netcdf.inqVarID(ncid,'XLAT');   latm =netcdf.getVar(ncid,varid);   y=double(latm);   
   lono=A(:,5); lato=A(:,6); height(fin);
%}   
%===============

   if vzind==1 || vzind==3
     C=vr;   type='vr';
%----cal----
     [xl yl mem]=size(varim);
     B=reshape(varim,xl*yl,mem);   
     Bt=mean(B,2);  
      Ct=mean(C);
     for i=1:mem; Be(:,i)=B(:,i)-Bt; end
      Ce=C-Ct;
     for i=1:xl*yl; varBe(i)=(Be(i,:)*Be(i,:)')/mem; end
      varCe=Ce*Ce'/mem;
     cov=(Ce*Be')./mem;
     corr0=cov./(varBe.^0.5)./(varCe^0.5);
     corr=reshape(corr0,xl,yl);
%---plot---
     %plot_corr(x,y,corr,L,cmap,lono,lato,fin)
if min(min(corr))<L(1); L2=[min(min(corr)),L]; else L2=[L(1) L]; end
figure('position',[500 100 600 500]) 
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c hp]=m_contourf(x,y,corr,L2);   set(hp,'linestyle','none');  hold on; 
m_plot(lono(fin),lato(fin),'ok','MarkerFaceColor',[0.1 0 0.1],'MarkerSize',7.3)
m_grid('fontsize',12);
% m_coast('color','k');
m_gshhs_h('color','k');
colorbar;   cm=colormap(cmap);    
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
     tit=[expri,'  ',vari,' ',type,'-',typem,'  ',s_hr,'z  (lev',num2str(lev),')'];
     title(tit,'fontsize',15)
     outfile=[outdir,filenam,'_',type,typem,'_',s_hr,'.png'];
     print('-dpng',outfile,'-r350')
%}
   end
%===============
   if vzind==2 || vzind==3
     C=zh;  type='zh';
     clear B Be varBe 
%----cal----
     [xl yl mem]=size(varim);
     B=reshape(varim,xl*yl,mem);     
     Bt=mean(B,2);  
      Ct=mean(C);
     for i=1:mem; Be(:,i)=B(:,i)-Bt; end
      Ce=C-Ct;
     for i=1:xl*yl; varBe(i)=(Be(i,:)*Be(i,:)')/40; end
      varCe=Ce*Ce'/40;
     cov=(Ce*Be')./40;
     corr0=cov./(varBe.^0.5)./(varCe^0.5);
     corr=reshape(corr0,xl,yl);
%---plot---
     plot_corr(x,y,corr,L,cmap,lono,lato,fin)
%---
     tit=[expri,'  ',vari,' ',type,'-',typem,'  ',s_hr,'z  (lev',num2str(lev),')'];
     title(tit,'fontsize',15)
     outfile=[outdir,filenam,'_',type,typem,'_',s_hr,'.png'];
     print('-dpng',outfile,'-r350')
%}
   end
end
