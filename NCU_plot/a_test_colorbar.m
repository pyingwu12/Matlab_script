% figure('position',[100 500 600 500])
% 
%cmap=[ 0.85 0.85 0.85;   0.75 0.75 0.75;     0.55 0.55 0.55;    0.35 0.35 0.35 ];

cmap =[    0.3725    0.7176    0.9020;
    0.6490    0.8539    0.1969;
    0.9804    0.8565    0.1647;
    0.9412    0.3088    0.0431];


%
cm=colormap(cmap);  %caxis([L2(1) L(length(L))])  
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   
%save('/work/pwin/data/colormap_br5.mat','colormap_br5')
