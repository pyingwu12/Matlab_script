%function accum_diff(sth,acch,expri,plotid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% target: 'mean' or 'member'
sth=17; acch=3; expri='origm'; plotid=2;
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  
cmap=colormap_br;
%---setting---
vari='rainfall diff. from CTRL';  expdir=['/work/pwin/plot_cal/Rain/',expri];
type1='mean';   type2='PM';    type3='PMmod';
filenam=[expri,'_accum-ori_'];   
L=[60 -45 -30 -20 -10 -5 5 10 20 30 45 60];
%---
nt=0;
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=['/work/pwin/plot_cal/Rain/orig/obs_acci_',s_sth,s_edh,'.mat'];
    load (infile);           
    [ori_m ori_PM ori_PMmod]=calPM(wrfacci);
    
    infile2=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
    load (infile2);           
    [mean PM PMmod]=calPM(wrfacci);
    diff_m=mean-ori_m;
    diff_pm=PM-ori_PM;
    diff_pmm=PMmod-ori_PMmod;
    %
     L2=[min(min(diff_pm)) L];
     figure('position',[1800 100 600 500])
     m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
     [c hp]=m_contourf(xi,yj,diff_pm,L2);   set(hp,'linestyle','none');
     m_grid('fontsize',12);
     m_gshhs_h('color','k');
     %m_coast('color','k');
     colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert'); set(hc,'fontsize',13)
     tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type2,')'];
     title(tit,'fontsize',15)
     outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type2,'.png'];
     print('-dpng',outfile,'-r350')
     %}
   %{ 
  end
end



