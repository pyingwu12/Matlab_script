%function accum_impr(sth,acch,expri,plotid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% target: 'mean' or 'member'
sth=15; acch=3; expri='MRmb3'; plotid=2;
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  
%colormap_br(9,:)=[1 1 1]; colormap_br(12,:)=[1 0.7065 0.1608]; colormap_br(6,:)=[0.4 0.7843 0.9012]; 
%colormap_br(15,:)=[0.8059 0.1569 0.0400];
cmap=colormap_br;
%cmap=colormap_br([2 3 4 5 6 8 9 11 12 13 14 15 17],:);    
%---setting---
vari='rainfall improve';  expdir=['/work/pwin/plot_cal/Rain/',expri];
type1='mean';   type2='PM';    type3='PMmod';
filenam=[expri,'_accum-impr_'];   
%L=[-75 -60 -45 -30 -15 -5 5 15 30 45 60 75];
L=[-60 -45 -30 -20 -10 -5 5 10 20 30 45 60];
%---
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=['/work/pwin/plot_cal/Rain/orig/acci_',s_sth,s_edh,'.mat'];
    load (infile);           
    [ori_m ori_PM ori_PMmod]=calPM(acci);
    
    infile2=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
    load (infile2);           
    [mean PM PMmod]=calPM(wrfacci);
    
    impr_m=abs(ori_m-obsacci)-abs(mean-obsacci);
    impr_pm=abs(ori_PM-obsacci)-abs(PM-obsacci);
    impr_pmm=abs(ori_PMmod-obsacci)-abs(PMmod-obsacci);
  
    %
     vari_p=impr_pm; type=type2;
     %
     L2=[min(min(vari_p)) L];
     figure('position',[1800 100 600 500])
     m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
     [c hp]=m_contourf(xi,yj,vari_p,L2);   set(hp,'linestyle','none');
     m_grid('fontsize',12);
     m_gshhs_h('color','k');
     %m_coast('color','k');
     colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert'); set(hc,'fontsize',13)
     tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type,')'];
     title(tit,'fontsize',15)
     outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type,'.png'];
     print('-dpng',outfile,'-r350')
     %}
  end
end



