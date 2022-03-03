
clear linex liney 
%
len=1.5;   %length of the line (degree)
slopx=0; %integer 
slopy=1; %integer
lonA=120.2; latA=21.75;   
%=====from A to B==========
%%---difine xp, yp for profile---
    dis= ( (y-latA).^2 + (x-lonA).^2 );
    [mid mxI]=min(dis);    [dmin py]=min(mid);    px=mxI(py);    
 %---interpoltion---    
    i=0;  lonB=x(px,py); latB=y(px,py);
    while len>abs(x(px,py)-lonB) && len>abs(y(px,py)-latB)
      i=i+1;
      indx=px+slopx*(i-1);    indy=py+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);    
      liney(i)=y(indx,indy);  latB=liney(i);      
    end  
%=====from the center point======
 %---difine xp, yp for profile---
% dis= ( (y-p_lat).^2 + (x-p_lon).^2 );
% [mid mxI]=min(dis);    [~, py]=min(mid);    px=mxI(py);  

% n=0;  lonB=0; latB=0;
% while lonB<=x(px,py)+len/2 && latB<=y(px,py)+len/2
%  n=n+1; lonB=x(px+slopx*(n-1),py+slopy*(n-1));  latB=y(px+slopx*(n-1),py+slopy*(n-1));  
% end
 %
% np=n*2;  linex=zeros(1,np); liney=zeros(1,np); 
% for i=1:np
%  indx=px+slopx*(i-n);    indy=py+slopy*(i-n);
%  linex(i)=x(indx,indy);  liney(i)=y(indx,indy);   
% end
%linecolor=[0.1 0.3 0.2];
%linecolor=[0.15 0.5 0.1];
linecolor=[0.15 0.3 0.15];
hold on
m_line([linex(1) linex(end)],[liney(1) liney(end)],'color',linecolor,'LineStyle','--','LineWidth',2)
%
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'_.png']);
system(['rm ',[outfile,'.pdf']]); 
