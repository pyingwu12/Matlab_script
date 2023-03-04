function [mathmean, PM, PMmod]=calPM(variable)

% input: acci{1,ensemble size}(lon,lat).   (ensemble)
% output: mean, PM mean(Ebert,2001), Pmmod mean(Yeh,2014)
%--**notice: if there is any NaN values, it must be the same size and same position in every member**--

      mems=size(variable,2);
      [xl, yl]=size(variable{1});
      %---calculate mean, PM, PMmod---
      varleng=size(find(isnan(variable{1})~=1),1);    %% !! notice: only define NaN values accrodding member 1.
      mathmean=zeros(xl,yl);
      sortmean=zeros(varleng,1);
      for i=1:mems         
      %--tick NaN and reshape data to 1-dimention--
        vari2=variable{i}(isnan(variable{i})~=1);
        %racci=reshape(racci,accl,1);    
        %--
        allacci(varleng*(i-1)+1:varleng*i,1)=vari2;      % PM, disarrange all data           
        sortmean=sort(vari2)./mems+sortmean;       % PMmod, sort, then mean             
        mathmean=variable{i}./mems+mathmean;               % mean     
      end
      %--PM--
      sortall=sort(allacci);                       % sort
      if mod(mems,2)~=0
        hmem=(mems+1)/2;
        midsortall(1:varleng,1)=sortall(hmem:mems:varleng*mems-hmem+1);
      else   
        hmem=mems/2;
        midsortall(1:varleng,1)=(sortall(hmem:mems:varleng*mems-hmem)+sortall(hmem+1:mems:varleng*mems-hmem+1))./2;   % medium value
      end
      %--reput NaN data--
      midsortall(varleng+1:xl*yl,1)=NaN;             % PM
      sortmean(varleng+1:xl*yl)=NaN;                 % PMmod
      %--record the pattern of mean--
      rmeacci=reshape(mathmean,xl*yl,1);            % [xl*yl 1] with NaN rain data of mean
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