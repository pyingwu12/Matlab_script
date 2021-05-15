figure
x1 = 0:0.1:40;
y1 = 4.*cos(x1)./(x1+2);
plot(x1,y1,'Color','r')
ax1 = gca; % current axes
ax1.XColor = 'r';
ax1.YColor = 'r';

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,'XAxisLocation','top',...
    'YAxisLocation','right','Color','none');
%%
figure
X = randn(50,3); 
Y = reshape(1:150,50,3); 
[~,ax]=plotmatrix(X,Y); 
ax(1,1).YLabel.String='Test1'; 
ax(2,1).YLabel.String='Test2'; 
ax(3,1).YLabel.String='Test3'; 
ax(3,1).XLabel.String='Test7'; 
ax(3,2).XLabel.String='Test8'; 
ax(3,3).XLabel.String='Test9';
%%
figure
% Create a plot: 
plot([1 50 100],[5 10 12],'b-o')
% Set XTicks at desired locations for both km/h and mph:
set(gca,'xtick',[0 20 32.1869 40 60 64.3738 80 96.5606 100])
% Set XTickLabels at km/h locations, leave blank for mph:
set(gca,'xticklabel',{'0','20','','40','60','','80','','100'})
% Create text objects for the mph labels:
text([0; 32.1869; 64.3738; 96.5606],[4.4; 4.4; 4.4; 4.4],{'0','20','40','60'},'color','r','horizontalalignment','center')
% Create text objects for 'km/h' and 'mph':
text(-3,4.8,'km/h','horizontalalignment','right')
text(-3,4.4,'mph','horizontalalignment','right','color','r')