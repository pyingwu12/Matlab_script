clear
clf

y=[1   1.2   1.5   1.5   3.2;  
   5   4.5   6.6     6   8.1;
   5   6.5     8  10.5   7.3;
   3     2   1.9   4.2   3.5; 
   4   5.2   7.5   2.9   1.2 ];

yplot(1,:)=y(2,:); yplot(2,:)=y(4,:)-y(2,:);
yplot=yplot';

x=[1 3 4 5 8];

h=area(x,yplot,'LineWidth',2);

set(h(1),'FaceColor','none','EdgeColor','none')
set(h(2),'FaceColor',[0.7 0.7 0.7])  

title('Test matlab function area','fontsize',14);
grid on; set(gca, 'Layer','top')
