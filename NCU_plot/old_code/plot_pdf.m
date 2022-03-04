clear
close all 
%---setting---
sth=11:23;   acch=1;   fre=zeros(100,1);
%---
for ti=sth
  s_sth=num2str(ti);         % time string
  for ai=acch                % accumulation time
%---set clim and end time---    
    edh=ti+ai;               % end time
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read and add data---
    for j=1:ai
      hr1=num2str(ti+j-1);
      if ti+j==24; hr2='00'; else hr2=num2str(ti+j); end      
      infile=['/work/pwin/data/raingauge_new_1hr_20090808/20090808',hr1,hr2,'_raingauge.dat'];
      A=importdata(infile);  rain(:,j)=A(:,3);
      fin=find(rain(:,j)<0); rain(fin,j)=0;
    end
    acc=sum(rain,2);
%---interpolate---
    for i=1:length(acc)
      for h=1:100
        if acc(i)>=h && acc(i)<h+1  
         fre(h)=fre(h)+1;
        end
      end    
    end
    
  end
end
