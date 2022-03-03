function corr_obsmodel_submain(vonam,vmnam,memsize)
%-------------------------------------------------
%   Corr.(obs_point,model_2D-level) 
%-------------------------------------------------
%
%clear
%
hr=0;  minu='00';  
%vonam='Vr';  vmnam='U';  memsize=256;
sub=72/3; %must to be integer (grid numbers)

expri='largens'; type='wrfo';

%---experimental setting---
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 

%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br2.mat'; 
cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];    % 02Z
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=lower(vmnam(1:2));  else  s_vm=vmnam; end
corrvari=[vonam,'-',lower(s_vm)];
%
varinam=['Corr.',corrvari];    filenam=[expri,'_'];
%
plon=[118.5 122]; plat=[20.1 23.5];
%plon=[118.3 121.8];   plat=[21 24.3];
%if pradar==3; lonrad=120.8471; latrad=21.9026; elseif pradar==4; lonrad=120.086; latrad=23.1467; end
%
%---
   s_hr=num2str(hr,'%2.2d');

%   pradar=4;  pela=0.5;  paza=353;  pdis=103;  %pattern3
%   [corr(:,:,1) x(:,:,1) y(:,:,1) obslon(1) obslat(1) obshgt(1)]=...
%               corr_obsmodel_subfun(hr,minu,vonam,vmnam,memsize,pradar,pela,paza,pdis,sub);
   pradar=4;  pela=0.5;  paza=203;  pdis=83;   %pattern1
   [corr(:,:,2) x(:,:,2) y(:,:,2)  obslon(2) obslat(2) obshgt(2)]=...
               corr_obsmodel_subfun(hr,minu,vonam,vmnam,memsize,pradar,pela,paza,pdis,sub);

   pradar=3;  pela=0.5;  paza=203;  pdis=103;  %pattern2
   [corr(:,:,3) x(:,:,3) y(:,:,3)  obslon(3) obslat(3) obshgt(3)]=...
               corr_obsmodel_subfun(hr,minu,vonam,vmnam,memsize,pradar,pela,paza,pdis,sub);
%   pradar=3;  pela=0.5;  paza=68;  pdis=133;
%   [corr(:,:,4) x(:,:,4) y(:,:,4)  obslon(4) obslat(4) obshgt(4)]=...
%               corr_obsmodel_subfun(hr,minu,vonam,vmnam,memsize,pradar,pela,paza,pdis,sub);

%}
%---plot---
   pmin=double(min(min(min(corr))));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %
   dsize=sub*2+1;
   pointnam={'A','B','C','D'};
   for i=2:3
%   if i==2
%   [c hp]=m_contourf(x(:,:,2),y(:,:,2),corr(:,:,2),[-Inf -0.6 -0.5 -0.4 -0.3 -0.2 -0.1725 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6]);
%   set(hp,'linestyle','none');
%   else
   [c hp]=m_contourf(x(:,:,i),y(:,:,i),corr(:,:,i),[-Inf -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6]);   set(hp,'linestyle','none');  hold on
%   end
   %[c hp]=m_contourf(x(:,:,i),y(:,:,i),corr(:,:,i),L2);   set(hp,'linestyle','none');  hold on
   cm=colormap(cmap);   %caxis([L2(1) L(length(L))])
   hc=Recolor_contourf(hp,cm,L,'vert'); 

   if i==1 || i==2
   m_plot(obslon(i),obslat(i),'xk','MarkerSize',10,'LineWidth',2.6)
   else
   m_plot(obslon(i),obslat(i),'pk','MarkerSize',10,'Markerfacecolor','k')
   end
   m_text(obslon(i)+0.1,obslat(i)-0.1,pointnam{i},'fontsize',13,'FontWeight','bold')
   box_x=[x(1,1,i),x(dsize,1,i),x(dsize,dsize,i),x(1,dsize,i),x(1,1,i)];
   box_y=[y(1,1,i),y(dsize,1,i),y(dsize,dsize,i),y(1,dsize,i),y(1,1,i)];
   m_line(box_x,box_y,'color','k') 
   end
  set(hc,'fontsize',13,'LineWidth',1.1)
   
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   m_gshhs_h('color','k','LineWidth',0.8);
   %m_coast('color','k');
   
%   m_plot(p_lon,p_lat,'xk','MarkerSize',10,'LineWidth',2.3)                       % obs point
%   m_text(plon(2)-(plon(2)-plon(1))/4.5,plat(1)+(plat(2)-plat(1))/66,[num2str(pradar),'-',num2str(pela),'-',num2str(paza),'-',num2str(pdis)],'color',[0.4 0.4 0.4])
%   m_plot(lonrad,latrad,'^g','MarkerFaceColor',[0 1 0],'MarkerSize',7)          % radar position
%    the=0:0.01:2*pi;  xr=loc*sin(the)+p_lon;  yr=(loc)*cos(the)+p_lat;  
%    m_plot(xr,yr,'k','LineStyle','--','LineWidth',0.6);                           % localization radius
%    the=0:0.01:2*pi;  xr=loc*3*sin(the)+p_lon;  yr=(loc*3)*cos(the)+p_lat; 
%    m_plot(xr,yr,'k','LineStyle','--','LineWidth',0.6);
%   m_text(plon(1)+(plon(2)-plon(1))/72,plat(2)-(plat(2)-plat(1))/25,['obs height=',num2str(obs_hgt)],'fontsize',12,'color',[0.4 0.4 0.4]) % obs height
   %
%   lev=num2str(lev);  
   mem=num2str(memsize);
   %tit=[expri,'  ',varinam,'  ',s_hr,'z  (',type,' mem',mem,')'];  
   tit=['Corr.(',vonam,', ',s_vm,')','  ',mem,' members'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',corrvari,'_m',mem];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
   
              
