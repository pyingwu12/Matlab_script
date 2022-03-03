function [meacci PM PMmod]=calPM(acci)

% input: acci{1,ensemble size}(lon,lat).   (ensemble)
% output: mean, PM mean(Ebert,2001), Pmmod mean(Yeh,2014)
%--**notice: if there is any NaN values, it must be the same size and same position in every member**--

      mems=size(acci,2);
      [xl yl]=size(acci{1});
      %---calculate mean, PM, PMmod---
      accl=size(find(isnan(acci{1})~=1),1);    %% !! notice: only define NaN values accrodding member 1.
      meacci=zeros(xl,yl);
      sortmean=zeros(accl,1);
      for i=1:mems;         
      %--tick NaN and reshape data to 1-dimention--
        racci=acci{i}(isnan(acci{i})~=1);
        %racci=reshape(racci,accl,1);    
        %--
        allacci(accl*(i-1)+1:accl*i,1)=racci;      % PM, disarrange all data           
        sortmean=sort(racci)./mems+sortmean;       % PMmod, sort, then mean             
        meacci=acci{i}./mems+meacci;               % mean     
      end
      %--PM--
      sortall=sort(allacci);                       % sort
      if mod(mems,2)~=0
        hmem=(mems+1)/2;
        midsortall(1:accl,1)=sortall(hmem:mems:accl*mems-hmem+1);
      else   
        hmem=mems/2;
        midsortall(1:accl,1)=(sortall(hmem:mems:accl*mems-hmem)+sortall(hmem+1:mems:accl*mems-hmem+1))./2;   % medium value
      end
      %--reput NaN data--
      midsortall(accl+1:xl*yl,1)=NaN;             % PM
      sortmean(accl+1:xl*yl)=NaN;                 % PMmod
      %--record the pattern of mean--
      rmeacci=reshape(meacci,xl*yl,1);            % [xl*yl 1] with NaN rain data of mean
      [~,loc]=sort(rmeacci);             % loc : the location in original rmeacci of sortmeacci(1.2.3...)
      %--give the pattern to PM and PMmod--
      pm=zeros(xl*yl,1);
      pmmod=zeros(xl*yl,1);
      for k=1:xl*yl    
        pm(loc(k))=midsortall(k);  
        pmmod(loc(k)) =sortmean(k); 
      end
      %--reshape PM and PMmod to 2-dimention data--
      n=0;  PM=zeros(xl,yl); PMmod=zeros(xl,yl);
      for k=1:yl
        for j=1:xl
          n=n+1;
          PMmod(j,k)= pmmod(n); 
          PM(j,k)= pm(n); 
        end
      end      
      
end