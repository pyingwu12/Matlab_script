
acci=obsacci;

%---setting---
expri='obs';   vari='accumulation rainfall';  
filenam='newobs_accum_';
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn_',filenam]; end
%---set clim and end time---    
    if mod(ai,2)~=0; clim=[0 ai*75+25]; elseif ai>=6; clim=[0 400]; else clim=[0 ai*75]; end    % colorbar      
    if ctnid~=0; clim=[0 ctnid]; end       
    L=fix(clim(2)/17*(1:16));
    if clim(2)==250;      L=[ 5 10 20 30 40 50 60  70  85 100 120 140 160 180 200 230];
    elseif clim(2)==100;  L=[ 5 10 15 20 25 30 35  40  45  50  55  60  65  75  85  95];
    elseif clim(2)==300;  L=[10 20 30 40 55 70 90 110 120 140 160 180 200 220 250 280];  
    end

    figure('position',[500 100 600 500])
    m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
    [c hp]=m_contourf(xi,yj,acci,L);   set(hp,'linestyle','none');
    m_grid('fontsize',12);
    m_gshhs_h('color','k');
    %m_coast('color','k');
    colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');  
    set(hc,'fontsize',13)
    tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z'];
    title(tit,'fontsize',15)
    outfile=[filenam,s_sth,s_edh,'.png'];
    print('-dpng',outfile,'-r350')

