%function accum_mean(sth,acch,expri,plotid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% plotid: mean=1 PM=2 PMmod=4, PM+mean=3 and so on...
% texid: Mark max value when texid~=0
% ctnid: same colorbar maximum=ctnid when ctnid~=0
sth=18; acch=3; expri='MR15'; plotid=2; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  
%colormap_br(9,:)=[1 1 1]; colormap_br(12,:)=[1 0.7065 0.1608]; colormap_br(6,:)=[0.4 0.7843 0.9012]; 
%colormap_br(15,:)=[0.8059 0.1569 0.0400];
cmap=colormap_br;
%cmap=colormap_br([2 3 4 5 6 8 9 11 12 13 14 15 17],:);   
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%L=[-95 -80 -65 -50 -40 -30 -20 -10 10 20 30 40 50 65 80 95];
L=[-110 -90 -70 -50 -30 -10 10 30 50 70 90 110];
%L=[60 -45 -30 -20 -10 -5 5 10 20 30 45 60];
%L=[-40 -35 -30 -25 -20 -15 -10 -5 5 10 15 20 25 30 35 40];
%---setting---
vari='accumulation rainfall';  expdir=['/work/pwin/plot_cal/Rain/',expri];
type1='mean';   type2='PM';    type3='PMmod';
filenam=[expri,'_accum-inno_'];   
%---
for ti=sth;
   s_sth=num2str(ti);
   for ai=acch;
%---set end time---    
      edh=ti+ai;               % end time
      if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
      infile=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
      load (infile);
      [meacci PM PMmod]=calPM(wrfacci); 
      meacci_o=obsacci-meacci;
      PM_o=obsacci-PM;
      PMmod=obsacci-PMmod;
      %
%---plot---
%---mean---
      if plotid==1 || plotid==3 || plotid==5 || plotid==7
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c hp]=m_contourf(xi,yj,meacci_o,L);   set(hp,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        %m_coast('color','k');
        colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');  
        tit=['obs- ',expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type1,')'];
        title(tit,'fontsize',15)
        outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type1,'.png'];
        print('-dpng',outfile,'-r350')
      end
%---PM---   
      if plotid==2 || plotid==3 || plotid==6 || plotid==7
        L2=[min(min(PM_o)) L];
        figure('position',[1800 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c hp]=m_contourf(xi,yj,PM_o,L2);   set(hp,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        %m_coast('color','k');
        colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)    
        tit=['obs-',expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type2,')'];
        title(tit,'fontsize',15)
        outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type2,'.png'];
        print('-dpng',outfile,'-r350')
      end
%---PMmod---
      if plotid==4 || plotid==5 || plotid==6 || plotid==7
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c hp]=m_contourf(xi,yj,PMmod_o,L);   set(hp,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        %m_coast('color','k');
        colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13)  
        tit=['obs- ',expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type3,')'];
        title(tit,'fontsize',15)
        outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type3,'.png'];
        print('-dpng',outfile,'-r350')  
      end
      %}
   end
end  

%}
